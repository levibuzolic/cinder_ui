defmodule CinderUI.HooksSourceTest do
  use ExUnit.Case, async: true

  @repo_root Path.expand("../..", __DIR__)

  test "assembled hook artifact matches modular sources" do
    {output, status} =
      System.cmd("node", ["bin/build-cinder-ui-js", "--check"],
        cd: @repo_root,
        stderr_to_stdout: true
      )

    assert status == 0, output
  end
end
