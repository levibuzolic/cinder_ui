defmodule CinderUI.HooksSourceTest do
  use ExUnit.Case, async: true

  @repo_root Path.expand("../..", __DIR__)

  test "assembled hook artifact is generated instead of tracked" do
    {_output, status} =
      System.cmd("git", ["ls-files", "--error-unmatch", "priv/templates/cinder_ui.js"],
        cd: @repo_root,
        stderr_to_stdout: true
      )

    assert status != 0
  end

  test "assembled hook artifact exposes public exports without source imports" do
    js = CinderUI.Assets.cinder_ui_js()

    assert js =~ "export const CinderUIHooks"
    assert js =~ "export const CinderUI"
    refute js =~ ~r/^import \{/m
  end
end
