# 不想更改源码时，可以在配置文件中继承类后进行指定
# 我选的这种方案，比较灵活好用，不破坏环境
# -----------------------
# 假设jupyterhub --generate-config生成文件在这个位置
# vim ~/.jupyter/hubDIY/jupyterhub_config.py
# 在这个文件中写入
# -----------------------
import os
import json
import logging
from jupyterhub.auth import Authenticator
from jupyterhub.spawner import SimpleLocalProcessSpawner
from tornado import gen

# 定义允许的用户及其密码
def load_user_passwords():
    with open('./jupyterhub_password.json', 'r') as f:
        return json.load(f)
# 加载用户密码数据
ALLOWED_USERS = load_user_passwords()

class MyCustomSpawner(SimpleLocalProcessSpawner):
    def user_env(self, env):
        # 设置自定义环境变量
        env['USER'] = os.environ.get('USER', 'hnzhao')
        env['HOME'] = os.environ.get('HOME', '/appsnew/home/hnzhao')
        env['SHELL'] = os.environ.get('SHELL', '/usr/bin/zsh')
        return env

class MyCustomAuthenticator(Authenticator):
    @gen.coroutine
    def authenticate(self, handler, data):
        # 调试输出
        logging.info(f"Attempting to authenticate user: {data['username']}")
        username = data['username']
        password = data['password']

        # 调试输出
        logging.info(f"Username provided: {username}")
        logging.info(f"Password provided: {password}")

        # 检查用户名和密码是否匹配
        if username in ALLOWED_USERS and ALLOWED_USERS[username] == password:
            logging.info(f"User {username} authenticated successfully.")
            return username  # 登录成功
        else:
            logging.warning(f"Authentication failed for user: {username}")
            return None  # 登录失败

c.Authenticator.allowed_users = set(ALLOWED_USERS.keys())
c.Spawner.notebook_dir = os.environ.get('HOME', '/appsnew/home/hnzhao')
c.Spawner.default_url = '/lab'
c.Spawner.args = ['--allow-root']


c.Spawner.http_timeout = 240
c.Spawner.start_timeout = 240
c.JupyterHub.authenticator_class = MyCustomAuthenticator
c.JupyterHub.spawner_class = MyCustomSpawner


# 为jupyterhub 添加额外服务，用于处理闲置用户进程。使用时不好使安装一下：pip install jupyterhub-ilde-culler
# c.JupyterHub.services = [
    # {
        # 'name': 'idle-culler',
        # 'command': ['python3', '-m', 'jupyterhub_idle_culler', '--timeout=3600'],
        # 'admin':True # 1.5.0 需要服务管理员权限，去kill 部分闲置的进程notebook, 2.0版本已经改了，可以只赋给 idel-culler 部分特定权限，roles
    # }
# ]


