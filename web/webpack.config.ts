// SPDX-FileCopyrightText: Copyright (C) 2023-2026 Bayerische Motoren Werke Aktiengesellschaft (BMW AG)<lichtblick@bmwgroup.com>
// SPDX-License-Identifier: MPL-2.0

// This Source Code Form is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import path from "path";

import {
  ConfigParams,
  devServerConfig,
  mainConfig,
} from "@lichtblick/suite-web/src/webpackConfigs";

import packageJson from "../package.json";

const params: ConfigParams = {
  // Where the bundle lands. __dirname resolves somewhere unexpected on the
  // Vercel builder — the build reported "compiled successfully" while
  // web/.webpack was never created — so the deploy passes an absolute path
  // instead and leaves local builds on the default.
  outputPath: process.env.LICHTBLICK_OUT
    ? path.resolve(process.env.LICHTBLICK_OUT)
    : path.resolve(__dirname, ".webpack"),
  contextPath: path.resolve(__dirname, "src"),
  entrypoint: "./entrypoint.tsx",
  // No source maps in the published build: they were 128 MB of the 170 MB
  // output and this deployment is public, while the source is on GitHub.
  prodSourceMap: false,
  version: packageJson.version,
};

// foxglove-depcheck-used: webpack-dev-server
export default [devServerConfig(params), mainConfig(params)];
