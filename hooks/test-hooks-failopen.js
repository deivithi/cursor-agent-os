#!/usr/bin/env node
/**
 * Gauntlet local: stdin sem EOF não pode travar hook até o timeout do harness.
 */
const { spawn } = require("child_process");
const path = require("path");

const ROOT = __dirname;

function run(script, { write, endStdin, maxMs }) {
  return new Promise((resolve, reject) => {
    const started = Date.now();
    const child = spawn(process.execPath, [path.join(ROOT, script)], {
      stdio: ["pipe", "pipe", "pipe"],
      windowsHide: true,
    });
    let stderr = "";
    child.stderr.on("data", (d) => {
      stderr += d.toString();
    });
    if (write) child.stdin.write(write);
    if (endStdin) child.stdin.end();
    const killer = setTimeout(() => {
      child.kill();
      reject(new Error(`${script} exceeded ${maxMs}ms (still hung)`));
    }, maxMs);
    child.on("exit", (code) => {
      clearTimeout(killer);
      resolve({
        script,
        code: code === null ? -1 : code,
        ms: Date.now() - started,
        stderr: stderr.slice(0, 200),
      });
    });
  });
}

async function main() {
  const cases = await Promise.all([
    run("profile-session.js", {
      write: '{"cwd":"C:\\\\tmp"}',
      endStdin: false,
      maxMs: 3500,
    }),
    run("prettier-after-edit.js", {
      write: "{}",
      endStdin: true,
      maxMs: 2500,
    }),
    run("git-safety-guard.js", {
      write: '{"tool_name":"Read"}',
      endStdin: true,
      maxMs: 2500,
    }),
  ]);

  let failed = 0;
  for (const c of cases) {
    const ok = c.code === 0 && c.ms < 3000;
    if (!ok) failed += 1;
    console.log(
      `${ok ? "PASS" : "FAIL"} ${c.script} exit=${c.code} ${c.ms}ms`
    );
    if (c.stderr) console.log(`  stderr: ${c.stderr}`);
  }
  process.exit(failed === 0 ? 0 : 1);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
