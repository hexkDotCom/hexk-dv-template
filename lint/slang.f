// SPDX-License-Identifier: 0BSD
//
// slang.f - options for make elab. Warnings are errors (style guide rule LNG-32); warnings in
// the UVM sources and in hexk-sv-lib are suppressed by path on the command line.

--std=1800-2017
--timescale=1ns/1ps
-Wextra
-Werror
