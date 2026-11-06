import { View, div, svg } from "gpui-kit";
import { v_flex, h_flex } from "gpui-base";
import { exec, readTextFile, home, appHome, theme } from "herdr";
import { readFile, writeFile } from "fs/promises";

// Herdr won't draw an SVG that is a symlink, and this folder's code may be linked in from
// elsewhere, so the icons live here as text and are written out as real files on load.
const REFRESH_SVG = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><path d="M20 11a8 8 0 1 0-2.3 5.7M20 4v7h-7"/></svg>\n`;

async function ensureFile(path, text) {
  try { if ((await readFile(path, "utf8")) === text) return; } catch { /* missing */ }
  await writeFile(path, text);
}

// Open GitLab MRs: draft, pipeline jobs, approvals. The Herdr twin of the mr-status
// Claude Code plugin; it reads that plugin's options (repos, author, pollSeconds) from
// ~/.claude/settings.json so the two always watch the same projects. Options left unset
// there take the installed plugin's own defaults, as the plugin does.

const DEFAULTS = { repos: "", author: "", pollSeconds: 60 };
const ACTIVE = new Set(["RUNNING", "PENDING", "PREPARING", "WAITING_FOR_RESOURCE", "CREATED", "SCHEDULED"]);

const readJson = async (path) => {
  try { const text = await readTextFile(path); return text ? JSON.parse(text) : null; } catch { return null; }
};
const mrStatusKey = (obj) => Object.keys(obj ?? {}).find((k) => k.startsWith("mr-status@"));

/** The installed mr-status plugin's userConfig defaults, or {} when it isn't installed. */
async function pluginDefaults() {
  const installed = (await readJson(`${home()}/.claude/plugins/installed_plugins.json`))?.plugins;
  const key = mrStatusKey(installed);
  const entries = key ? installed[key] : [];
  const entry = entries.find((e) => e.scope === "user") ?? entries[0];
  if (!entry?.installPath) return {};
  const manifest = await readJson(`${entry.installPath}/.claude-plugin/plugin.json`);
  return Object.fromEntries(Object.entries(manifest?.userConfig ?? {}).map(([k, v]) => [k, v?.default]));
}

async function loadConfig() {
  const settings = await readJson(`${home()}/.claude/settings.json`);
  const configs = settings?.pluginConfigs ?? {};
  const key = mrStatusKey(configs);
  const options = (key && configs[key].options) || {};
  const o = { ...DEFAULTS, ...(await pluginDefaults()), ...options };
  const seconds = Number(o.pollSeconds);
  return {
    repos: String(o.repos ?? "").split(/[\s,]+/).filter(Boolean),
    author: String(o.author ?? "").trim(),
    pollMs: Math.max(15, Number.isFinite(seconds) ? seconds : 60) * 1000,
  };
}

function buildQuery(hasAuthor) {
  const vars = hasAuthor ? "$path: ID!, $author: String!" : "$path: ID!";
  const filter = hasAuthor ? ", authorUsername: $author" : "";
  return `query(${vars}) { project(fullPath: $path) { mergeRequests(state: opened, first: 50, sort: UPDATED_DESC${filter}) { nodes {
    iid title webUrl draft approved approvalsLeft updatedAt
    author { username }
    approvedBy { nodes { username } }
    headPipeline { status jobs(retried: false) { nodes { name status allowFailure } } }
  } } } }`;
}

function parseReply(repo, stdout) {
  const body = JSON.parse(stdout);
  if (body.errors?.[0]) throw new Error(body.errors[0].message);
  if (!body.data?.project) throw new Error("project not found");
  return body.data.project.mergeRequests.nodes.map((n) => {
    // GitLab lists jobs newest stage first; the strip reads oldest first.
    const jobs = [...(n.headPipeline?.jobs?.nodes ?? [])].reverse();
    return {
      repo, iid: n.iid, url: n.webUrl,
      title: n.title.replace(/^Draft:\s*/i, ""),
      author: n.author?.username ?? "?",
      isDraft: n.draft, isApproved: n.approved === true,
      approvalsLeft: n.approvalsLeft ?? 0,
      approvedBy: (n.approvedBy?.nodes ?? []).map((u) => u.username),
      pipeline: n.headPipeline?.status ?? "NONE",
      jobs: jobs.map((j) => ({ name: j.name, status: j.status === "FAILED" && j.allowFailure ? "ALLOWED_FAILURE" : j.status })),
      failedJobs: jobs.filter((j) => j.status === "FAILED" && !j.allowFailure).map((j) => j.name),
      runningJobs: jobs.filter((j) => ACTIVE.has(j.status)).map((j) => j.name),
    };
  });
}

function health(mr) {
  if (mr.failedJobs.length > 0 || mr.pipeline === "FAILED") return "failed";
  if (mr.pipeline === "SUCCESS") return "passed";
  if (mr.pipeline === "NONE") return "none";
  if (ACTIVE.has(mr.pipeline) || mr.runningJobs.length > 0) return "running";
  return "other";
}

const sortMrs = (list) => [...list.filter((m) => !m.isDraft), ...list.filter((m) => m.isDraft)];
const shortTitle = (title) => title.replace(/^[a-z]+(?:\([^)]*\))?!?:\s*/, "");
const firstLine = (text) => (text ?? "").trim().split("\n")[0] ?? "";

export default class Mrs extends View {
  init(_props, cx) {
    this.mrs = []; this.errors = []; this.fetchedAt = 0; this.loading = false;
    this.collapsed = {}; this.me = null; this.config = null;
    cx.spawn(async (cx) => {
      ensureFile(`${appHome()}/mods/mrs/refresh.svg`, REFRESH_SVG).catch(() => {});
      this.config = await loadConfig();
      cx.notify();
      this.refresh(cx);
      cx.timer.every(this.config.pollMs, (cx) => this.refresh(cx));
    });
  }

  async resolveAuthor(author) {
    if (author !== "@me") return author.replace(/^@/, "");
    if (this.me) return this.me;
    const r = await exec("glab", ["api", "user"]);
    if (r.code !== 0) throw new Error(`glab api user: ${firstLine(r.stderr)}`);
    this.me = JSON.parse(r.stdout).username;
    return this.me;
  }

  refresh(cx) {
    if (this.loading || !this.config) return;
    this.loading = true;
    cx.notify();
    cx.spawn(async (cx) => {
      // Re-read the plugin's options each time, so a /config change shows up here too.
      const config = this.config = { ...(await loadConfig()), pollMs: this.config.pollMs };
      const found = [], failed = [];
      try {
        let author = "";
        try { author = config.author ? await this.resolveAuthor(config.author) : ""; }
        catch (e) { failed.push(String(e?.message ?? e)); }
        const query = buildQuery(author !== "");
        await Promise.all(config.repos.map(async (repo) => {
          const args = ["api", "graphql", "-f", `query=${query}`, "-f", `path=${repo}`];
          if (author) args.push("-f", `author=${author}`);
          try {
            const r = await exec("glab", args);
            if (r.code !== 0) throw new Error(firstLine(r.stderr) || `exit ${r.code}`);
            found.push(...parseReply(repo, r.stdout));
          } catch (e) { failed.push(`${repo}: ${e?.message ?? e}`); }
        }));
        this.mrs = found; this.errors = failed; this.fetchedAt = Date.now();
      } finally { this.loading = false; cx.notify(); }
    });
  }

  glyph(mr, t) {
    const h = health(mr);
    const look = {
      failed: ["✗", t.ansi1], running: ["◐", t.working], passed: ["✓", t.ansi2],
      none: ["○", t.dim], other: ["◌", t.dim],
    }[h];
    return mr.isDraft && h !== "failed" ? ["◌", look[1]] : look;
  }

  jobCell(job, i, t) {
    const color = {
      SUCCESS: t.ansi2, FAILED: t.ansi1, ALLOWED_FAILURE: t.blocked, RUNNING: t.working,
    }[job.status] ?? t.border;
    const hollow = ["MANUAL", "SKIPPED", "CANCELED", "CREATED"].includes(job.status);
    const cell = div().w(7).h(10).flex_none().rounded(2);
    const look = hollow ? cell.border_1().border_color(t.dim) : cell.bg(color);
    return job.status === "RUNNING" ? look.loop("opacity", { from: 0.35, to: 1, period: 1100 }) : look;
  }

  mrRow(mr, t) {
    const [icon, color] = this.glyph(mr, t);
    const have = mr.approvedBy.length, need = Math.max(have + mr.approvalsLeft, have, 1);
    const dim = mr.isDraft;
    const jobs = mr.jobs.slice(0, 24);
    const sub = mr.failedJobs.length ? mr.failedJobs.join(", ") : this.config?.author ? "" : `@${mr.author}`;
    return v_flex().id(`mr-${mr.repo}-${mr.iid}`).px(8).py(5).gap(4).rounded(7).cursor_pointer()
      .hover((s) => s.bg(t.hover))
      .on_click(() => exec("open", [mr.url]))
      .child(h_flex().gap(7).items_center()
        .child(div().w(12).flex_none().text_color(color).child(icon))
        .child(div().flex_none().font_semibold().text_color(dim ? t.dim : t.foreground).child(`!${mr.iid}`))
        .child(div().flex_1().min_w(0).truncate().text_color(dim ? t.muted : t.foreground).child(shortTitle(mr.title)))
        .when(dim, (e) => e.child(div().flex_none().px(4).rounded(4).border_1().border_color(t.border).text_size(10).text_color(t.dim).child("draft")))
        .child(div().flex_none().text_size(11).text_color(mr.isApproved ? t.ansi2 : t.dim).child(`${mr.isApproved ? "◆" : "◇"}${have}/${need}`)))
      .when(jobs.length > 0 || Boolean(sub), (e) => e.child(h_flex().pl(19).gap(6).items_center()
        .child(h_flex().gap(2).flex_none().items_center().when(dim, (s) => s.opacity(0.6)).children(jobs.map((j, i) => this.jobCell(j, i, t))))
        .when(mr.jobs.length > jobs.length, (s) => s.child(div().flex_none().text_size(10).text_color(t.dim).child(`+${mr.jobs.length - jobs.length}`)))
        .child(div().flex_1().min_w(0).truncate().text_size(11).text_color(mr.failedJobs.length ? t.ansi1 : t.dim).child(sub))));
  }

  repoSection(repo, t, cx) {
    const rows = sortMrs(this.mrs.filter((m) => m.repo === repo));
    const count = (h) => rows.filter((m) => health(m) === h).length;
    const failing = count("failed"), running = count("running"), passed = count("passed");
    const folded = this.collapsed[repo] ?? rows.length === 0;
    const name = repo.slice(repo.lastIndexOf("/") + 1);
    // Each repo is a card; its border takes the colour of its worst pipeline, as the
    // Claude Code pane's boxes do.
    const edge = failing > 0 ? t.ansi1 + "99" : running > 0 ? t.working + "99" : t.border;
    return v_flex().flex_none().rounded(8).overflow_hidden().border_1().border_color(edge).bg(t.surface)
      .child(h_flex().id(`repo-${repo}`).h(30).px(10).gap(6).items_center().cursor_pointer().hover((s) => s.bg(t.hover))
        .when(!folded && rows.length > 0, (e) => e.border_b(1).border_color(t.border))
        .on_click((_e, cx) => { this.collapsed[repo] = !folded; cx.notify(); })
        .child(svg(`mods/files/${folded ? "chevron-right" : "chevron-down"}.svg`).size(12).flex_none().text_color(t.dim))
        .child(div().flex_1().min_w(0).truncate().font_semibold().text_color(rows.length ? t.foreground : t.muted).child(name))
        .when(failing > 0, (e) => e.child(div().text_size(11).text_color(t.ansi1).child(`✗${failing}`)))
        .when(running > 0, (e) => e.child(div().text_size(11).text_color(t.working).child(`◐${running}`)))
        .when(passed > 0, (e) => e.child(div().text_size(11).text_color(t.ansi2).child(`✓${passed}`)))
        .child(div().text_size(11).text_color(t.dim).child(this.fetchedAt ? `${rows.length}` : "…")))
      .when(!folded && rows.length > 0, (e) => e.child(v_flex().p(4).gap(1).children(rows.map((mr) => this.mrRow(mr, t)))));
  }

  render(cx) {
    const t = theme();
    const repos = this.config?.repos ?? [];
    const total = this.mrs.length;
    const failing = this.mrs.filter((m) => health(m) === "failed").length;
    // Repos with open MRs first, in the configured order otherwise.
    const ordered = [...repos.filter((r) => this.mrs.some((m) => m.repo === r)), ...repos.filter((r) => !this.mrs.some((m) => m.repo === r))];
    const d = new Date(this.fetchedAt);
    const stamp = this.fetchedAt ? `${d.getHours() % 12 || 12}:${String(d.getMinutes()).padStart(2, "0")}` : "…";
    return v_flex().id("mrs").size_full().min_h(0).rounded(10).overflow_hidden().bg(t.background).border_1().border_color(t.border).text_color(t.foreground).text_size(13)
      .child(h_flex().h(42).flex_none().px(14).gap(8).items_center().border_b(1).border_color(t.border)
        .child(div().font_semibold().child("Merge requests"))
        .child(div().px(5).py(1).rounded(4).border_1().border_color(t.border).text_size(10).text_color(t.muted).child(`${total} open`))
        .when(failing > 0, (e) => e.child(div().px(5).py(1).rounded(4).text_size(10).bg(t.ansi1 + "26").text_color(t.ansi1).child(`${failing} failing`)))
        .child(div().flex_1())
        .child(div().id("mrs-refresh").size(24).flex().items_center().justify_center().rounded(6).cursor_pointer().text_color(t.dim)
          .hover((s) => s.bg(t.hover).text_color(t.foreground))
          .on_click((_e, cx) => this.refresh(cx))
          .child(this.loading
            ? svg("mods/workspace-chrome/spinner.svg").size(14).text_color(t.working).spin(900)
            : svg("mods/mrs/refresh.svg").size(14))))
      .child(v_flex().id("mrs-list").flex_1().min_h(0).overflow_y_scrollbar().p(8).gap(8)
        .when(this.config && repos.length === 0, (e) => e.child(div().p(8).text_color(t.blocked).child("No repos set. Set mr-status repos in Claude Code /config.")))
        .children(this.errors.map((p, i) => div().id(`err-${i}`).px(8).py(4).text_size(11).text_color(t.ansi1).child(`✗ ${p}`)))
        .when(!this.config, (e) => e.child(div().p(8).text_color(t.dim).child("Loading…")))
        .children(ordered.map((r) => this.repoSection(r, t, cx))))
      .child(h_flex().h(28).flex_none().px(14).gap(6).items_center().border_t(1).border_color(t.border).text_size(11).text_color(t.dim)
        .child(div().child(`↻ ${stamp}`))
        .child(div().child("·"))
        .child(div().flex_1().min_w(0).truncate().child(this.config?.author || "everyone"))
        .child(div().child(`${(this.config?.pollMs ?? 60000) / 1000}s`)));
  }
}
