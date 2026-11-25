#!/usr/bin/env node
/**
 * aib_guard.mjs — AI Usage Barometer Lifecycle Hook Guard
 * - --post: Fast syntax check on edited .sh / .json files (<100ms)
 * - --stop: Runs verify-release.sh --fast when worktree has changes; blocks stop on violation
 */
import * as fs from "fs";
import * as path from "path";
import { execFileSync } from "child_process";

const mode = process.argv[2] || "--post";
const repoRoot = path.resolve(path.dirname(new URL(import.meta.url).pathname), "..");

async function readStdinJson() {
  let input = "";
  process.stdin.setEncoding("utf-8");
  for await (const chunk of process.stdin) {
    input += chunk;
  }
  if (!input.trim()) return {};
  try {
    return JSON.parse(input);
  } catch {
    return {};
  }
}

async function handlePost(payload) {
  const args = payload.toolCall?.args || payload.args || payload.parameters || {};
  const filePath = args.Path || args.path || args.TargetFile || args.filePath || args.targetFile;
  if (typeof filePath === "string" && fs.existsSync(filePath)) {
    if (filePath.endsWith(".sh")) {
      execFileSync("bash", ["-n", filePath], { stdio: "ignore", timeout: 5000 });
    } else if (filePath.endsWith(".json")) {
      JSON.parse(fs.readFileSync(filePath, "utf-8"));
    }
  }
  process.stdout.write(JSON.stringify({}) + "\n");
}

async function handleStop(payload) {
  // Only gate normal turn completions when fully idle
  if (payload.terminationReason && payload.terminationReason !== "NO_TOOL_CALL") {
    process.stdout.write(JSON.stringify({ decision: "allow" }) + "\n");
    return;
  }
  if (payload.fullyIdle === false) {
    process.stdout.write(JSON.stringify({ decision: "allow" }) + "\n");
    return;
  }

  let dirty = "";
  try {
    dirty = execFileSync("git", ["-C", repoRoot, "status", "--porcelain"], {
      encoding: "utf-8",
      timeout: 5000,
    }).trim();
  } catch {
    process.stdout.write(JSON.stringify({ decision: "allow" }) + "\n");
    return;
  }

  if (!dirty) {
    process.stdout.write(JSON.stringify({ decision: "allow" }) + "\n");
    return;
  }

  try {
    execFileSync("bash", [path.join(repoRoot, "scripts", "verify-release.sh"), "--fast"], {
      cwd: repoRoot,
      encoding: "utf-8",
      stdio: ["ignore", "pipe", "pipe"],
      timeout: 15000,
    });
    process.stdout.write(JSON.stringify({ decision: "allow" }) + "\n");
  } catch (err) {
    const stderr = (err.stderr || err.stdout || err.message || "").toString().trim().slice(0, 600);
    process.stdout.write(
      JSON.stringify({
        decision: "continue",
        reason: `⚠️ AI Usage Barometer Release Gate (verify-release.sh --fast) failed:\n${stderr}\nPlease fix the invariant violation before finishing.`,
      }) + "\n"
    );
  }
}

async function main() {
  const payload = await readStdinJson();
  if (mode === "--stop") {
    await handleStop(payload);
  } else {
    await handlePost(payload);
  }
}

main().catch(() => {
  process.stdout.write(JSON.stringify(mode === "--stop" ? { decision: "allow" } : {}) + "\n");
  process.exit(0);
});
