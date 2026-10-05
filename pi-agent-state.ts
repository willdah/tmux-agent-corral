// Reports Pi's state to the tmux agents panel through agent-state; see that
// script for the protocol. Linked into ~/.pi/agent/extensions by install.sh.
// Pi has no permission prompts of its own, so ▲ only shows while an extension
// asks something (ui_prompt_*).
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { execFileSync } from "node:child_process";
import { homedir } from "node:os";

const cmd = `${homedir()}/.config/tmux/agents/agent-state`;

// Synchronous so the clear on quit lands before Pi exits; a failure must
// never get in the agent's way.
function state(s: string) {
  if (!process.env.TMUX_PANE) return;
  try {
    execFileSync(cmd, [s, "pi"], { stdio: "ignore", timeout: 5000 });
  } catch {}
}

export default function (pi: ExtensionAPI) {
  pi.on("session_start", () => state("idle"));
  pi.on("agent_start", () => state("running"));
  pi.on("ui_prompt_start", () => state("input"));
  pi.on("ui_prompt_end", () => state("running"));
  pi.on("agent_settled", () => state("done"));
  pi.on("session_shutdown", () => state("clear"));
}
