#!/usr/bin/env python3

from cmd2 import Cmd, options, make_option
import sys
import os
import subprocess
import coloredlogs
import logging


logger = logging.getLogger(__name__)
coloredlogs.install(level='DEBUG')


class InitShell(Cmd):
    """Ujuc computes init"""

    prompt = "install>>>"
    intro = "Welllllllllll...."

    def __init__(self):
        # 무조건 cmd 로 접근하여 작업을 하려면 해당 내용을 사용한다
        # self.allow_cli_args = False
        pass

    # todo: install system package
    def do_system_pkg(self, arg, opts=None):
        pass

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


    def do_eof(self, arg):
        print("\n")
        logger.info("bye bye")
        return self._STOP_AND_EXIT


if __name__ == '__main__':
    shell = InitShell()
    shell.cmdloop()
