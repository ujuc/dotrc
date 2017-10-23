#!/usr/bin/env python3
"""System Settings

Sungjin (ujuc@ujuc.kr)
"""

import inspect
import logging
import os
import platform
import subprocess

import coloredlogs
from cmd2 import Cmd, make_option, options

try:
    import distro
except ImportError:
    pass

__version__ = '1.0-rc'

logger = logging.getLogger(__name__)
coloredlogs.install(level='DEBUG')


class InitShell(Cmd):
    """Ujuc computes init"""

    prompt = "psh >>"
    intro = "Welllllllllll...."

    path_home = os.environ['HOME']
    path_pwd = os.path.dirname(os.path.abspath(inspect.getfile(
        inspect.currentframe())))

    def __init__(self):
        # 무조건 cmd 로 접근하여 작업을 하려면 해당 내용을 사용한다
        # self.allow_cli_args = False
        Cmd.__init__(self, use_ipython=True)

    def do_system_pkg(self, arg):
        """
        install system package
        """
        sysname = platform.uname().system
        logging.debug(f"system is {sysname}")
        logging.info("install pkg")

        if sysname == "Darwin":
            subprocess.run(["xcode-select", "--install"])
            subprocess.run(["sudo", "xcodebuild", "-license"])

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

    @options([
        make_option('--tmux', action="store_true", default=False),
        make_option('--tig', action="store_true", default=False),
    ])
    def do_link_dotrc(self, arg, opts=None):
        """
        Linked *rc file without vimrc
        """
        logging.info("Start linking dotrc")

        if not opts.tmux and not opts.tig:
            self.symlink_rc("tmux.conf")
            self.symlink_rc("tigrc")
        elif opts.tmux:
            self.symlink_rc("tmux.conf")
        elif opts.tig:
            self.symlink_rc("tigrc")

    @options([
        make_option('--zsh', action="store_true", default=False),
        make_option('--zplug', action="store_true", default=False),
        make_option('--config', action="store_true", default=False),
    ])
    def do_zsh(self, arg, opts=None):
        """Install and configure zsh"""

        def install_zsh():
            logging.info("install zsh")

            subprocess.run([
                "curl", "-o", "/tmp/install.sh",
                "https://gist.githubusercontent.com/ujuc/"
                "0a27fd5c81a5f277f391e75683c469e8/raw/"
                "5c1b52db9362c36df5c9bae15921dbf8b5239866/install_oh-my-zsh.sh"
            ], stdout=subprocess.PIPE, encoding='utf-8')

            work_zsh = subprocess.run([
                "bash", f"/tmp/install.sh"
            ], stdout=subprocess.PIPE, encoding='utf-8')
            logging.debug(work_zsh)

            self.symlink_rc("zshrc")

            logging.info("installed oh-my-zsh")

        def install_zplug():
            logging.info("install zplug")

            work_zplug = subprocess.run([
                "git", "clone", "https://github.com/zplug/zplug",
                f"{self.path_home}/.zplug"
            ], stdout=subprocess.PIPE, encoding='utf-8')

            logging.debug(work_zplug)
            logging.info("installed zplug")

        def config_zsh():
            # todo: zsh 를 실행시키고 해당 값을 변경해줘야된다.
            logging.info("todo: configure zsh")
            logging.info("exit > zsh > zplug install > source ~/.zshrc")

        if not opts.zsh and not opts.zplug and not opts.config:
            install_zsh()
            install_zplug()
            config_zsh()
        elif opts.zsh:
            install_zsh()
        elif opts.zplug:
            install_zplug()
        elif opts.config:
            config_zsh()

    def do_powerline_font(self, arg):
        """install powerline font"""
        logging.info("install powerline font")
        subprocess.run(["bash", f"{self.path_pwd}/fonts/install.sh"])

    def do_vim(self, arg):
        """Configure vim"""
        path_vim = f"{self.path_home}/.vim"
        os.mkdir(path_vim)
        os.mkdir(f"{path_vim}/bundle")
        os.mkdir(f"{path_vim}/vimundo")
        os.mkdir(f"{path_vim}/colors")

        logging.info("install vim-plug")
        work_vim_plug = subprocess.run([
            "git", "clone", "https://github.com/junegunn/vim-plug.git",
            f"{path_vim}/autoload/"
        ], stdout=subprocess.PIPE, encoding='utf-8')
        logging.debug(work_vim_plug)
        logging.info("installed vim-plug")

        logging.info("install amix/vimrc")
        subprocess.run([
            "git", "clone", "https://github.com/amix/vimrc.git",
            f"{self.path_home}/.vim_runtime"
        ], stdout=subprocess.PIPE, encoding='utf-8')
        work_vimrc = subprocess.run([
            "sh", f"{self.path_home}/.vim_runtime/install_awesome_vimrc.sh"
        ], stdout=subprocess.PIPE, encoding='utf-8')
        logging.debug(work_vimrc)
        logging.info("installed amix/vimrc")

        logging.info("configure custom vimrc")
        os.symlink(f"{self.path_pwd}/vimrcs", f"{self.path_home}/.vim/vimrcs")
        self.symlink_rc("vimrc")

        # todo: YCM 추가 필요
        # https://github.com/Valloric/YouCompleteMe.git

        subprocess.run(["vi", "+PlugInstall", "+qall"])
        logging.info("configured custom vimrc")

    # todo: Git 부분을 shell 로 불러오지 안도록 하자.
    def do_git(self, arg):
        subprocess.run(["git", "submodule", "init"])
        subprocess.run(["git", "submodule", "update"])

    def do_eof(self, arg):
        print("\n")
        logger.info("bye bye")
        return self._STOP_AND_EXIT

    def symlink_rc(self, file_name):
        try:
            os.lstat(f"{self.path_home}/.{file_name}")
            os.remove(f"{self.path_home}/.{file_name}")

            logging.info(f"Remove {file_name}")
        except FileNotFoundError:
            pass

        os.symlink(f"{self.path_pwd}/{file_name}",
                   f"{self.path_home}/.{file_name}")

        logging.info(f"Linked {file_name}")


if __name__ == '__main__':
    shell = InitShell()
    shell.cmdloop()
