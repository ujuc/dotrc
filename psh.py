#!/usr/bin/env python3

import logging
import platform
import subprocess

import coloredlogs
import distro
from cmd2 import Cmd

logger = logging.getLogger(__name__)
coloredlogs.install(level='DEBUG')


class InitShell(Cmd):
    """Ujuc computes init"""

    prompt = "install>>>"
    intro = "Welllllllllll...."

    def __init__(self):
        # 무조건 cmd 로 접근하여 작업을 하려면 해당 내용을 사용한다
        # self.allow_cli_args = False
        Cmd.__init__(self, use_ipython=True)

    def do_system_pkg(self):
        """
        OS에 따라 필요한 Package를 설치한다.
        """
        sysname = platform.uname()
        logging.debug(f"system is {sysname}")
        logging.info("install pkg")

        if sysname == "Darwin":
            output = subprocess.run(
                ["which", "brew"],
                stdout=subprocess.PIPE, encoding='utf-8')

            logging.info(f"check brew {output}")

            if output is '':
                install_brew = subprocess.run([
                    "ruby", "-e",
                    "\"$(curl -fsSL https://raw.githubusercontent.com/Homebrew"
                    "/install/master/install)\""
                ], stdout=subprocess.PIPE, encoding='utf-8')
                install_cask = subprocess.run([
                    "brew", "tap", "caskroom/cask"
                ], stdout=subprocess.PIPE, encoding='utf-8')

                logging.debug(install_brew)
                logging.debug(install_cask)

            install_pkg = subprocess.run([
                "brew", "install", "tmux", "tig", "zsh"
            ], stdout=subprocess.PIPE, encoding='utf-8')

            logging.debug(install_pkg)

            install_vim = subprocess.run([
                "brew", "install", "vim",
                "--with-python3", "--with-override-system-vi"
            ], stdout=subprocess.PIPE, encoding='utf-8')

            logging.debug(install_vim)

            install_font_hack = subprocess.run([
                "brew", "cask", "install",
                "font-hack", "font-hack-nerd-font-mono"
            ], stdout=subprocess.PIPE, encoding='utf-8')

            logging.debug(install_font_hack)

        elif sysname == "Linux":
            distro_name = distro.id()
            logging.debug(f"distro {distro_name}")

            if distro_name == "ubuntu":
                install_pkg = subprocess.run([
                    "sudo", "apt", "install", "-y",
                    "vim", "tig", "tmux", "zsh", "openssh-server"
                ], stdout=subprocess.PIPE, encoding='utf-8')

            elif distro_name == "manjaro":
                install_pkg = subprocess.run([
                    "yaourt", "-S", "vim", "tig", "zsh", "openssh"
                ], stdout=subprocess.PIPE, encoding='utf-8')

            logging.debug(install_pkg)

            # todo: arch 용은 따로 만들어야될듯... (언젠가)

    # todo: linked *rc file without vimrc
    def do_link_dotrc(self):
        pass

    # todo: install zsh
    def do_zsh(self):
        pass

    # todo: configure vim
    def do_vim(self):
        pass

    # todo: Git 부분을 shell 로 불러오지 안도록 하자.
    def do_git(self):
        pass

    def do_eof(self, arg):
        print("\n")
        logger.info("bye bye")
        return self._STOP_AND_EXIT


if __name__ == '__main__':
    shell = InitShell()
    shell.cmdloop()
