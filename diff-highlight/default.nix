{ linkFarm
, gitAndTools
}:

linkFarm "diff-highlight" [{
  name = "bin/diff-highlight";
  path = "${gitAndTools.gitFull}/share/git/contrib/diff-highlight/diff-highlight";
}]
