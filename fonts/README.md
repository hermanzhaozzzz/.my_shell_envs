# install fonts on linux

```bash
mkdir -p ~/.local/share/fonts
cp Helvetica*.ttf ~/.local/share/fonts/
# 刷新字体缓存
fc-cache -f -v
# 验证字体是否安装成功
fc-list | grep -i helvetica
# 如果能看到类似输出，说明字体
# /home/yourname/.local/share/fonts/HelveticaNeue.ttf: Helvetica Neue:style=Regular
```

# matplotlib 中使用 Helvetica

```python
import matplotlib.pyplot as plt
plt.rcParams["font.family"] = "Helvetica"
# matplotlib 缓存未更新?
# rm ~/.cache/matplotlib -rf
```

