#!/usr/bin/env node

const { program } = require('commander');
const path = require('path');
const { spawn } = require('child_process');

const pkg = require('../package.json');
const ROOT_DIR = path.resolve(__dirname, '..');
const RUN_SH = path.join(ROOT_DIR, 'run.sh');

program
  .name('rbin-install-dev')
  .description('Development environment setup for Linux and macOS')
  .version(pkg.version);

program
  .command('init')
  .description('Run the installer (modo pessoal ou empresa, scripts de ambiente)')
  .option('--force-install', 'Reinstall everything, even if already installed')
  .option('-f, --force', 'Skip confirmation prompts')
  .option('-v, --verbose', 'Enable verbose logging')
  .action((options) => {
    const { existsSync } = require('fs');
    if (!existsSync(RUN_SH)) {
      console.error('Error: run.sh not found at', RUN_SH);
      process.exit(1);
    }

    const args = [];
    if (options.forceInstall) args.push('--force-install');
    if (options.force) args.push('--force');
    if (options.verbose) args.push('--verbose');

    const child = spawn('bash', [RUN_SH, ...args], {
      stdio: 'inherit',
      cwd: ROOT_DIR,
      env: { ...process.env, RBIN_INSTALL_DEV_ROOT: ROOT_DIR }
    });

    child.on('close', (code) => {
      process.exit(code ?? 0);
    });

    child.on('error', (err) => {
      console.error('Failed to run installer:', err.message);
      process.exit(1);
    });
  });

program
  .command('info')
  .description('Show information about rbin-install-dev')
  .action(() => {
    console.log('\n  rbin-install-dev – development environment setup (Linux / macOS)');
    console.log('  Version:', pkg.version);
    console.log('\n  Usage:');
    console.log('    rbin-install-dev init                  Run the installer');
    console.log('    rbin-install-dev init --force-install  Reinstall all tools');
    console.log('    rbin-install-dev init --force          Skip confirmation prompts');
    console.log('    rbin-install-dev init -v                 Verbose logging');
    console.log('');
  });

program.parse();
