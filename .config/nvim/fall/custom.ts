import type { Entrypoint } from "jsr:@vim-fall/custom@^0.1.0";
import {
  composeActions,
  composeRenderers,
  refineCurator,
  refineSource,
} from "jsr:@vim-fall/std@^0.10.0";
import * as builtin from "jsr:@vim-fall/std@^0.10.0/builtin";
import * as extra from "jsr:@vim-fall/extra@^0.2.0";
import { SEPARATOR } from "jsr:@std/path@^1.0.8/constants";

//import { file } from "http://localhost:6000/file:///Users/alisue/ogh/vim-fall/deno-fall-std/builtin/source/file.ts";
import { MODERN_THEME } from "http://localhost:6000/file:///Users/alisue/ogh/vim-fall/deno-fall-std/builtin/theme/modern.ts";
import { ASCII_THEME } from "http://localhost:6000/file:///Users/alisue/ogh/vim-fall/deno-fall-std/builtin/theme/ascii.ts";

// NOTE:
//
// Install https://github.com/BurntSushi/ripgrep to use 'builtin.curator.rg'
// Install https://www.nerdfonts.com/ to use 'builtin.renderer.nerdfont'
// Install https://github.com/thinca/vim-qfreplace to use 'Qfreplace'
//

const coordinator = builtin.coordinator.modern;

const myPathActions = {
  ...builtin.action.defaultOpenActions,
  ...builtin.action.defaultSystemopenActions,
  ...builtin.action.defaultCdActions,
};

const myQuickfixActions = {
  ...builtin.action.defaultQuickfixActions,
  "quickfix:qfreplace": builtin.action.quickfix({
    after: "Qfreplace",
  }),
};

const myMiscActions = {
  ...builtin.action.defaultEchoActions,
  ...builtin.action.defaultYankActions,
  ...builtin.action.defaultSubmatchActions,
};

const myFilterFile = (path: string) => {
  const excludes = [
    ".7z",
    ".DS_Store",
    ".avi",
    ".avi",
    ".bmp",
    ".class",
    ".dll",
    ".dmg",
    ".doc",
    ".docx",
    ".dylib",
    ".ear",
    ".exe",
    ".fla",
    ".flac",
    ".flv",
    ".gif",
    ".ico",
    ".id_ed25519",
    ".id_rsa",
    ".iso",
    ".jar",
    ".jpeg",
    ".jpg",
    ".key",
    ".mkv",
    ".mov",
    ".mp3",
    ".mp4",
    ".mpeg",
    ".mpg",
    ".o",
    ".obj",
    ".ogg",
    ".pdf",
    ".png",
    ".ppt",
    ".pptx",
    ".rar",
    ".so",
    ".swf",
    ".tar.gz",
    ".war",
    ".wav",
    ".webm",
    ".wma",
    ".wmv",
    ".xls",
    ".xlsx",
    ".zip",
    "id_ed25519",
    "id_rsa",
  ];
  for (const exclude of excludes) {
    if (path.endsWith(exclude)) {
      return false;
    }
  }
  return true;
};

const myFilterDirectory = (path: string) => {
  const excludes = [
    "$RECYVLE.BIN",
    ".cache",
    ".git",
    ".hg",
    ".ssh",
    ".svn",
    "__pycache__", // Python
    "build", // C/C++
    "node_modules", // Node.js
    "target", // Rust
    ".coverage",
    `nvim${SEPARATOR}pack`,
    `zsh${SEPARATOR}.addons`,
    `karabiner${SEPARATOR}automatic_backups`,
  ];
  for (const exclude of excludes) {
    if (path.endsWith(`${SEPARATOR}${exclude}`)) {
      return false;
    }
  }
  return true;
};

export const main: Entrypoint = ({
  definePickerFromSource,
  definePickerFromCurator,
  refineSetting,
}) => {
  refineSetting({
    coordinator: coordinator({
      widthRatio: 0.9,
      heightRatio: 0.8,
    }),
    theme: builtin.theme.MODERN_THEME,
    // theme: MODERN_THEME,
    // theme: ASCII_THEME,
  });

  definePickerFromCurator(
    "grep",
    refineCurator(builtin.curator.grep, builtin.refiner.relativePath),
    {
      sorters: [
        builtin.sorter.noop,
        builtin.sorter.lexical,
        builtin.sorter.lexical({ reverse: true }),
      ],
      renderers: [builtin.renderer.nerdfont, builtin.renderer.noop],
      previewers: [builtin.previewer.file],
      actions: {
        ...myPathActions,
        ...myQuickfixActions,
        ...myMiscActions,
      },
      defaultAction: "open",
    },
  );

  definePickerFromCurator(
    "git-grep",
    refineCurator(builtin.curator.gitGrep, builtin.refiner.relativePath),
    {
      sorters: [
        builtin.sorter.noop,
        builtin.sorter.lexical,
        builtin.sorter.lexical({ reverse: true }),
      ],
      renderers: [builtin.renderer.nerdfont, builtin.renderer.noop],
      previewers: [builtin.previewer.file],
      actions: {
        ...myPathActions,
        ...myQuickfixActions,
        ...myMiscActions,
      },
      defaultAction: "open",
    },
  );

  definePickerFromCurator(
    "rg",
    refineCurator(builtin.curator.rg, builtin.refiner.relativePath),
    {
      sorters: [
        builtin.sorter.noop,
        builtin.sorter.lexical,
        builtin.sorter.lexical({ reverse: true }),
      ],
      renderers: [builtin.renderer.nerdfont, builtin.renderer.noop],
      previewers: [builtin.previewer.file],
      actions: {
        ...myPathActions,
        ...myQuickfixActions,
        ...myMiscActions,
      },
      defaultAction: "open",
    },
  );

  definePickerFromSource("mru", extra.source.mr, {
    matchers: [builtin.matcher.fzf],
    sorters: [
      builtin.sorter.noop,
      builtin.sorter.lexical,
      builtin.sorter.lexical({ reverse: true }),
    ],
    renderers: [
      composeRenderers(builtin.renderer.smartPath, builtin.renderer.nerdfont),
      builtin.renderer.nerdfont,
      builtin.renderer.noop,
    ],
    previewers: [builtin.previewer.file],
    actions: {
      ...myPathActions,
      ...myQuickfixActions,
      ...myMiscActions,
      ...extra.action.defaultMrDeleteActions,
    },
    defaultAction: "open",
  });

  definePickerFromSource(
    "mrw",
    refineSource(
      extra.source.mr({ type: "mrw" }),
      builtin.refiner.cwd,
      builtin.refiner.relativePath,
    ),
    {
      matchers: [builtin.matcher.fzf],
      sorters: [
        builtin.sorter.noop,
        builtin.sorter.lexical,
        builtin.sorter.lexical({ reverse: true }),
      ],
      renderers: [
        composeRenderers(builtin.renderer.smartPath, builtin.renderer.nerdfont),
        builtin.renderer.nerdfont,
        builtin.renderer.noop,
      ],
      previewers: [builtin.previewer.file],
      actions: {
        ...myPathActions,
        ...myQuickfixActions,
        ...myMiscActions,
        ...extra.action.defaultMrDeleteActions,
      },
      defaultAction: "open",
    },
  );

  definePickerFromSource("mrr", extra.source.mr({ type: "mrr" }), {
    matchers: [builtin.matcher.fzf],
    renderers: [
      composeRenderers(builtin.renderer.smartPath, builtin.renderer.nerdfont),
      builtin.renderer.nerdfont,
      builtin.renderer.noop,
    ],
    actions: {
      ...myPathActions,
      ...myQuickfixActions,
      ...myMiscActions,
      ...extra.action.defaultMrDeleteActions,
      "cd-and-open": composeActions(builtin.action.cd, builtin.action.open),
    },
    defaultAction: "cd-and-open",
    coordinator: coordinator({
      hidePreview: true,
    }),
  });

  definePickerFromSource("mrd", extra.source.mr({ type: "mrd" }), {
    matchers: [builtin.matcher.fzf],
    renderers: [
      composeRenderers(builtin.renderer.smartPath, builtin.renderer.nerdfont),
      builtin.renderer.nerdfont,
      builtin.renderer.noop,
    ],
    actions: {
      ...myPathActions,
      ...myQuickfixActions,
      ...myMiscActions,
      ...extra.action.defaultMrDeleteActions,
      "cd-and-open": composeActions(builtin.action.cd, builtin.action.open),
    },
    defaultAction: "cd-and-open",
    coordinator: coordinator({
      hidePreview: true,
    }),
  });

  definePickerFromSource(
    "file",
    refineSource(
      builtin.source.file({
        filterFile: myFilterFile,
        filterDirectory: myFilterDirectory,
        relativeFromBase: true,
      }),
      builtin.refiner.relativePath,
    ),
    {
      matchers: [builtin.matcher.fzf, builtin.matcher.regexp],
      sorters: [
        builtin.sorter.noop,
        builtin.sorter.lexical,
        builtin.sorter.lexical({ reverse: true }),
      ],
      renderers: [
        composeRenderers(builtin.renderer.smartPath, builtin.renderer.nerdfont),
        builtin.renderer.nerdfont,
        builtin.renderer.noop,
      ],
      previewers: [builtin.previewer.file, builtin.previewer.noop],
      actions: {
        ...myPathActions,
        ...myQuickfixActions,
        ...myMiscActions,
      },
      defaultAction: "open",
    },
  );

  definePickerFromSource(
    "file:all",
    refineSource(builtin.source.file, builtin.refiner.relativePath),
    {
      matchers: [builtin.matcher.fzf],
      sorters: [
        builtin.sorter.noop,
        builtin.sorter.lexical,
        builtin.sorter.lexical({ reverse: true }),
      ],
      renderers: [
        composeRenderers(builtin.renderer.smartPath, builtin.renderer.nerdfont),
        builtin.renderer.nerdfont,
        builtin.renderer.noop,
      ],
      previewers: [builtin.previewer.file],
      actions: {
        ...myPathActions,
        ...myQuickfixActions,
        ...myMiscActions,
      },
      defaultAction: "open",
    },
  );

  definePickerFromSource("line", builtin.source.line, {
    matchers: [builtin.matcher.fzf],
    previewers: [builtin.previewer.buffer],
    actions: {
      ...myQuickfixActions,
      ...myMiscActions,
      ...builtin.action.defaultOpenActions,
      ...builtin.action.defaultBufferActions,
    },
    defaultAction: "open",
  });

  definePickerFromSource(
    "buffer",
    builtin.source.buffer({ filter: "bufloaded" }),
    {
      matchers: [builtin.matcher.fzf],
      sorters: [
        builtin.sorter.noop,
        builtin.sorter.lexical,
        builtin.sorter.lexical({ reverse: true }),
      ],
      previewers: [builtin.previewer.buffer],
      actions: {
        ...myQuickfixActions,
        ...myMiscActions,
        ...builtin.action.defaultOpenActions,
        ...builtin.action.defaultBufferActions,
      },
      defaultAction: "open",
    },
  );

  definePickerFromSource("help", builtin.source.helptag, {
    matchers: [builtin.matcher.fzf],
    sorters: [
      builtin.sorter.noop,
      builtin.sorter.lexical,
      builtin.sorter.lexical({ reverse: true }),
    ],
    previewers: [builtin.previewer.helptag],
    actions: {
      ...myMiscActions,
      ...builtin.action.defaultHelpActions,
    },
    defaultAction: "help",
  });

  definePickerFromSource("quickfix", builtin.source.quickfix, {
    matchers: [builtin.matcher.fzf],
    sorters: [
      builtin.sorter.noop,
      builtin.sorter.lexical,
      builtin.sorter.lexical({ reverse: true }),
    ],
    previewers: [builtin.previewer.buffer],
    actions: {
      ...builtin.action.defaultOpenActions,
      ...myMiscActions,
    },
    defaultAction: "open",
  });

  definePickerFromSource(
    "oldfiles",
    refineSource(
      builtin.source.oldfiles,
      builtin.refiner.cwd,
      builtin.refiner.exists,
      builtin.refiner.relativePath,
    ),
    {
      matchers: [builtin.matcher.fzf],
      sorters: [
        builtin.sorter.noop,
        builtin.sorter.lexical,
        builtin.sorter.lexical({ reverse: true }),
      ],
      previewers: [builtin.previewer.file],
      actions: {
        ...myPathActions,
        ...myQuickfixActions,
        ...myMiscActions,
      },
      defaultAction: "open",
    },
  );

  definePickerFromSource("history", builtin.source.history, {
    matchers: [builtin.matcher.fzf],
    sorters: [
      builtin.sorter.noop,
      builtin.sorter.lexical,
      builtin.sorter.lexical({ reverse: true }),
    ],
    actions: {
      cmd: builtin.action.cmd({ immediate: true }),
      ...myMiscActions,
    },
    defaultAction: "cmd",
  });
};