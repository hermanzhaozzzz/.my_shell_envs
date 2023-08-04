df_points['log10_value'] = df_points['value1'].map(math.log10)


# sort_keys = df_points.groupby('<sample>').count().sort_values(by='chr', ascending=False).index
sort_keys = ['DetectSeq_SIRT6-DddA11_REP-1', 'DetectSeq_SIRT6-DddA11_REP-2',
             'DetectSeq_JAK2-DddA11_REP-1', 'DetectSeq_JAK2-DddA11_REP-2',
             'DetectSeq_ATP8-DddA11_REP-1', 'DetectSeq_ATP8-DddA6_REP-1', 'DetectSeq_ATP8-DddAwt_REP-1']
colors = ['#64C1E8',
          '#80CED7',
          '#5AB4C8',
          '#78C8C8',
          '#FF958C',
          '#D7BFF8',
          '#F8EDD0']
keys_colors = list(zip(sort_keys, colors))
raxis_range = [915, 1035]

for sort_key, color in keys_colors:
    df = df_points.query('`<sample>`==@sort_key')
    df = df.copy()
    
    df['pos'] = raxis_range[1] - raxis_range[0]
    raxis_range[0] = raxis_range[0] - 120
    raxis_range[1] = raxis_range[1] - 120
    print(raxis_range)
    vmin = df['log10_value'].min()
    vmax = df['log10_value'].max()
    
    for idx, point in df_chrom.iterrows():  # 考虑把它放外头
        circle.fillplot(
            point['chr'],
            data=df['pos'],
            # data=[raxis_range[1] - raxis_range[0]],
            rlim=[0, raxis_range[1] - raxis_range[0]],
            raxis_range=raxis_range,
            facecolor=color,
            edgecolor='white'
        )
    
    for chrom, point in df.groupby('chr'):
        # print(point)
        # print(color)
        
        circle.lineplot(
            chrom,
            data=point['log10_value'],
            # positions=(point['start'] + point['end']) / 2,
            rlim=[vmin - 0.05 * abs(vmin), vmax + 0.05 * abs(vmax)],
            raxis_range=raxis_range,
            # edgecolor='black',
            spine=True,
        )

circle.figure

## ---(Thu May 11 22:13:33 2023)---
"""Spyder Project: 3D genome and DdCBE project, analysis for final list.

Created on 2023-04-25

@author: Herman ZHAO
"""
import matplotlib.colors as mcolors
from matplotlib.patches import Rectangle
import matplotlib.pyplot as plt
import collections
import pycircos
import pandas as pd
import numpy as np
from glob import glob
import os
import sys
import math
sys.path.append('/Volumes/zhaohn_HD/Bio/3.project/2022_DdCBE-3D-Genome_topic/2022-09-30_Detect-seq_batch-1_ATP8_JAK2_SIRT6')
Garc = pycircos.Garc
Gcircle = pycircos.Gcircle
import sys
sys.path.append('/Volumes/zhaohn_HD/Bio/3.project/2022_DdCBE-3D-Genome_topic/2022-09-30_Detect-seq_batch-1_ATP8_JAK2_SIRT6')
import matplotlib.colors as mcolors
from matplotlib.patches import Rectangle
import matplotlib.pyplot as plt
import collections
import pycircos
import pandas as pd
import numpy as np
from glob import glob
import os
import sys
import math
sys.path.append('/Volumes/zhaohn_HD/Bio/3.project/2022_DdCBE-3D-Genome_topic/2022-09-30_Detect-seq_batch-1_ATP8_JAK2_SIRT6')
Garc = pycircos.Garc
Gcircle = pycircos.Gcircle
import matplotlib.colors as mcolors
from matplotlib.patches import Rectangle
import matplotlib.pyplot as plt
import collections
import pycircos
import pandas as pd
import numpy as np
from glob import glob
import os
import math
from bioat.lib.libcircos import Garc, Gcircle
# Garc = pycircos.Garc
# Gcircle = pycircos.Gcircle
import matplotlib.colors as mcolors
from matplotlib.patches import Rectangle
import matplotlib.pyplot as plt
import collections
import pycircos
import pandas as pd
import numpy as np
from glob import glob
import os
import math
from bioat.lib.libcircos import Garc, Gcircle
pd.set_option("display.width", 120)  # dataframe宽度
pd.set_option("display.max_columns", None)  # column最大显示数
pd.set_option("display.max_rows", 50)  # row最大显示数

# % set directory
os.chdir("/Volumes/zhaohn_HD/Bio/3.project/2022_DdCBE-3D-Genome_topic/2022-09-30_Detect-seq_batch-1_ATP8_JAK2_SIRT6/")
os.listdir()
def plot_colortable(colors, *, ncols=4, sort_colors=True, labels=None):
    
    cell_width = 212
    cell_height = 22
    swatch_width = 48
    margin = 12
    
    names = list(colors)
    
    if not labels:
        labels = names
    
    n = len(names)
    nrows = math.ceil(n / ncols)
    
    width = cell_width * 4 + 2 * margin
    height = cell_height * nrows + 2 * margin
    dpi = 72
    
    fig, ax = plt.subplots(figsize=(width / dpi, height / dpi), dpi=dpi)
    fig.subplots_adjust(margin / width, margin / height,
                        (width - margin) / width, (height - margin) / height)
    ax.set_xlim(0, cell_width * 4)
    ax.set_ylim(cell_height * (nrows - 0.5), -cell_height / 2.)
    ax.yaxis.set_visible(False)
    ax.xaxis.set_visible(False)
    ax.set_axis_off()
    
    for i, name in enumerate(names):
        row = i % nrows
        col = i // nrows
        y = row * cell_height
        
        swatch_start_x = cell_width * col
        text_pos_x = cell_width * col + swatch_width + 7
        
        ax.text(text_pos_x, y, labels[i], fontsize=14,
                horizontalalignment='left',
                verticalalignment='center')
        
        ax.add_patch(
            Rectangle(xy=(swatch_start_x, y - 9), width=swatch_width,
                      height=18, facecolor=name, edgecolor='0.7')
        )
    
    return fig
colors = ['#64C1E8',
          '#80CED7',
          '#63C7B2',
          '#8E6C88',
          '#CA61C3',
          '#FF958C',
          '#883677']
plot_colortable(colors, ncols=1, labels=[1, 2, 3, 4, 5, 6, 7])
circle = Gcircle()
df_chrom = pd.read_csv("pycircos/project_data/chromosome_length_hg38.csv")
df_chrom = df_chrom[df_chrom['chr'].map(lambda x: x not in ['chrY', 'chrM'])].copy()


for idx, row in df_chrom.iterrows():
    arc = Garc(arc_id=row['chr'], size=row['end'],
               interspace=1, raxis_range=(920, 950), labelposition=40, label_visible=True, facecolor='#FFFFFF')
    circle.add_garc(arc)
circle.set_garcs()
circle.figure
color_dict = {"gneg": "#FFFFFF00", "gpos25": "#EEEEEE", "gpos50": "#BBBBBB", "gpos75": "#777777", "gpos100": "#000000",
              "gvar": "#FFFFFF00", "stalk": "#C01E27", "acen": "#D82322"}

arcdata_dict = collections.defaultdict(dict)
with open("pycircos/project_data/cytoBand_hg38.csv") as f:
    f.readline()
    for line in f:
        line = line.rstrip().split(",")
        name = line[0]
        if name in ['chrY', 'chrM']:
            continue
        start = int(line[1]) - 1
        width = int(line[2]) - (int(line[1]) - 1)
        if name not in arcdata_dict:
            arcdata_dict[name]["positions"] = []
            arcdata_dict[name]["widths"] = []
            arcdata_dict[name]["colors"] = []
        arcdata_dict[name]["positions"].append(start)
        arcdata_dict[name]["widths"].append(width)
        arcdata_dict[name]["colors"].append(color_dict[line[-1]])

for key in arcdata_dict:
    circle.barplot(key, data=[1] * len(arcdata_dict[key]["positions"]), positions=arcdata_dict[key]["positions"],
                   width=arcdata_dict[key]["widths"], raxis_range=[920, 950], facecolor=arcdata_dict[key]["colors"])

circle.figure
df_points = pd.read_csv('final_list_after_igv_check/2023-04-24_merged_final_list_add_header_poisson_result.csv',
                        usecols=['<sample>', 'chr_name', 'region_start', 'region_end', 'treat_mut_count.norm'])
df_points.columns = ['<sample>', 'chr', 'start', 'end', 'value1']


df_points['log10_value'] = df_points['value1'].map(math.log10)


# sort_keys = df_points.groupby('<sample>').count().sort_values(by='chr', ascending=False).index
sort_keys = ['DetectSeq_SIRT6-DddA11_REP-1', 'DetectSeq_SIRT6-DddA11_REP-2',
             'DetectSeq_JAK2-DddA11_REP-1', 'DetectSeq_JAK2-DddA11_REP-2',
             'DetectSeq_ATP8-DddA11_REP-1', 'DetectSeq_ATP8-DddA6_REP-1', 'DetectSeq_ATP8-DddAwt_REP-1']
colors = ['#64C1E8',
          '#80CED7',
          '#5AB4C8',
          '#78C8C8',
          '#FF958C',
          '#D7BFF8',
          '#F8EDD0']
keys_colors = list(zip(sort_keys, colors))
raxis_range = [915, 1035]

for sort_key, color in keys_colors:
    df = df_points.query('`<sample>`==@sort_key')
    df = df.copy()
    
    df['pos'] = raxis_range[1] - raxis_range[0]
    raxis_range[0] = raxis_range[0] - 120
    raxis_range[1] = raxis_range[1] - 120
    print(raxis_range)
    vmin = df['log10_value'].min()
    vmax = df['log10_value'].max()
    
    for idx, point in df_chrom.iterrows():  # 考虑把它放外头
        circle.fillplot(
            point['chr'],
            data=df['pos'],
            # data=[raxis_range[1] - raxis_range[0]],
            rlim=[0, raxis_range[1] - raxis_range[0]],
            raxis_range=raxis_range,
            facecolor=color,
            edgecolor='white'
        )
    
    for chrom, point in df.groupby('chr'):
        # print(point)
        # print(color)
        
        circle.scatterplot(
            chrom,
            data=point['log10_value'],
            positions=(point['start'] + point['end']) / 2,
            rlim=[vmin - 0.05 * abs(vmin), vmax + 0.05 * abs(vmax)],
            raxis_range=raxis_range,
            facecolor="#3B6181",
            # edgecolor='black',
            spine=True,
            markersize=5
        )

circle.figure
from matplotlib.patches import Rectangle
import matplotlib.pyplot as plt
import collections
import pandas as pd
import numpy as np
from glob import glob
import os
import math
from bioat.lib.libcircos import Garc, Gcircle
pd.set_option("display.width", 120)  # dataframe宽度
pd.set_option("display.max_columns", None)  # column最大显示数
pd.set_option("display.max_rows", 50)  # row最大显示数

# % set directory
os.chdir("/Volumes/zhaohn_HD/Bio/3.project/2022_DdCBE-3D-Genome_topic/2022-09-30_Detect-seq_batch-1_ATP8_JAK2_SIRT6/")
os.listdir()
def plot_colortable(colors, *, ncols=4, sort_colors=True, labels=None):
    
    cell_width = 212
    cell_height = 22
    swatch_width = 48
    margin = 12
    
    names = list(colors)
    
    if not labels:
        labels = names
    
    n = len(names)
    nrows = math.ceil(n / ncols)
    
    width = cell_width * 4 + 2 * margin
    height = cell_height * nrows + 2 * margin
    dpi = 72
    
    fig, ax = plt.subplots(figsize=(width / dpi, height / dpi), dpi=dpi)
    fig.subplots_adjust(margin / width, margin / height,
                        (width - margin) / width, (height - margin) / height)
    ax.set_xlim(0, cell_width * 4)
    ax.set_ylim(cell_height * (nrows - 0.5), -cell_height / 2.)
    ax.yaxis.set_visible(False)
    ax.xaxis.set_visible(False)
    ax.set_axis_off()
    
    for i, name in enumerate(names):
        row = i % nrows
        col = i // nrows
        y = row * cell_height
        
        swatch_start_x = cell_width * col
        text_pos_x = cell_width * col + swatch_width + 7
        
        ax.text(text_pos_x, y, labels[i], fontsize=14,
                horizontalalignment='left',
                verticalalignment='center')
        
        ax.add_patch(
            Rectangle(xy=(swatch_start_x, y - 9), width=swatch_width,
                      height=18, facecolor=name, edgecolor='0.7')
        )
    
    return fig
colors = ['#64C1E8',
          '#80CED7',
          '#63C7B2',
          '#8E6C88',
          '#CA61C3',
          '#FF958C',
          '#883677']
plot_colortable(colors, ncols=1, labels=[1, 2, 3, 4, 5, 6, 7])
circle = Gcircle()
df_chrom = pd.read_csv("pycircos/project_data/chromosome_length_hg38.csv")
df_chrom = df_chrom[df_chrom['chr'].map(lambda x: x not in ['chrY', 'chrM'])].copy()


for idx, row in df_chrom.iterrows():
    arc = Garc(arc_id=row['chr'], size=row['end'],
               interspace=1, raxis_range=(920, 950), labelposition=40, label_visible=True, facecolor='#FFFFFF')
    circle.add_garc(arc)
circle.set_garcs()
circle.figure
color_dict = {"gneg": "#FFFFFF00", "gpos25": "#EEEEEE", "gpos50": "#BBBBBB", "gpos75": "#777777", "gpos100": "#000000",
              "gvar": "#FFFFFF00", "stalk": "#C01E27", "acen": "#D82322"}

arcdata_dict = collections.defaultdict(dict)
with open("pycircos/project_data/cytoBand_hg38.csv") as f:
    f.readline()
    for line in f:
        line = line.rstrip().split(",")
        name = line[0]
        if name in ['chrY', 'chrM']:
            continue
        start = int(line[1]) - 1
        width = int(line[2]) - (int(line[1]) - 1)
        if name not in arcdata_dict:
            arcdata_dict[name]["positions"] = []
            arcdata_dict[name]["widths"] = []
            arcdata_dict[name]["colors"] = []
        arcdata_dict[name]["positions"].append(start)
        arcdata_dict[name]["widths"].append(width)
        arcdata_dict[name]["colors"].append(color_dict[line[-1]])

for key in arcdata_dict:
    circle.barplot(key, data=[1] * len(arcdata_dict[key]["positions"]), positions=arcdata_dict[key]["positions"],
                   width=arcdata_dict[key]["widths"], raxis_range=[920, 950], facecolor=arcdata_dict[key]["colors"])

circle.figure
df_points = pd.read_csv('final_list_after_igv_check/2023-04-24_merged_final_list_add_header_poisson_result.csv',
                        usecols=['<sample>', 'chr_name', 'region_start', 'region_end', 'treat_mut_count.norm'])
df_points.columns = ['<sample>', 'chr', 'start', 'end', 'value1']


df_points['log10_value'] = df_points['value1'].map(math.log10)


# sort_keys = df_points.groupby('<sample>').count().sort_values(by='chr', ascending=False).index
sort_keys = ['DetectSeq_SIRT6-DddA11_REP-1', 'DetectSeq_SIRT6-DddA11_REP-2',
             'DetectSeq_JAK2-DddA11_REP-1', 'DetectSeq_JAK2-DddA11_REP-2',
             'DetectSeq_ATP8-DddA11_REP-1', 'DetectSeq_ATP8-DddA6_REP-1', 'DetectSeq_ATP8-DddAwt_REP-1']
colors = ['#64C1E8',
          '#80CED7',
          '#5AB4C8',
          '#78C8C8',
          '#FF958C',
          '#D7BFF8',
          '#F8EDD0']
keys_colors = list(zip(sort_keys, colors))
raxis_range = [915, 1035]

for sort_key, color in keys_colors:
    df = df_points.query('`<sample>`==@sort_key')
    df = df.copy()
    
    df['pos'] = raxis_range[1] - raxis_range[0]
    raxis_range[0] = raxis_range[0] - 120
    raxis_range[1] = raxis_range[1] - 120
    print(raxis_range)
    vmin = df['log10_value'].min()
    vmax = df['log10_value'].max()
    
    for idx, point in df_chrom.iterrows():  # 考虑把它放外头
        circle.fillplot(
            point['chr'],
            data=df['pos'],
            # data=[raxis_range[1] - raxis_range[0]],
            rlim=[0, raxis_range[1] - raxis_range[0]],
            raxis_range=raxis_range,
            facecolor=color,
            edgecolor='white'
        )
    
    for chrom, point in df.groupby('chr'):
        # print(point)
        # print(color)
        
        circle.scatterplot(
            chrom,
            data=point['log10_value'],
            positions=(point['start'] + point['end']) / 2,
            rlim=[vmin - 0.05 * abs(vmin), vmax + 0.05 * abs(vmax)],
            raxis_range=raxis_range,
            facecolor="#3B6181",
            # edgecolor='black',
            spine=True,
            markersize=5
        )

circle.figure
circle.figure.savefig("pycircos/project_out.pdf", dpi=300)
df_sort_keys = pd.DataFrame(sort_keys, columns=['<sample>'])
df_sort_values = df_points.groupby('<sample>').count()['chr'].reset_index()
labels = pd.merge(df_sort_keys, df_sort_values).apply(
    lambda x: f'{x["<sample>"]} (n={x["chr"]})', axis=1
)

plot_colortable(colors=colors, ncols=1, labels=labels.tolist())
plt.savefig("pycircos/project_out_legend.pdf")
arts = sorted(glob('art/DetectSeq_*.art'))


ls_arts = []

for art in arts:
    print(art)
    df = pd.read_csv(art, sep='\t')
    df['file_info'] = art
    ls_arts.append(df)

df_arts = pd.concat(ls_arts)
df_arts_tale_dep = (
    df_arts.sort_values(by=['align_total_mismatch', 'align_degen_total_mismatch', 'align_total_gap'])
    .query('align_total_mismatch<=4')
    .query('align_degen_total_mismatch<=4')
    .query('align_total_gap<=2')
)

df_arts_tale_dep.groupby('file_info').describe()[('start', 'count')]


df_arts_tale_dep[['<sample>', 'TAS-Dep_stat']] = (
    df_arts_tale_dep['file_info']
    .str.split('/')
    .str[-1]
    .str.replace('.art', '')
    .str.split('_TALE_align.', expand=True)
)

df_arts_tale_dep.groupby('<sample>')['TAS-Dep_stat'].value_counts()


# print(df_arts_tale_dep.groupby('<sample>')['TAS-Dep_stat'].count())
# print(df_arts_tale_dep.groupby('<sample>')['TAS-Dep_stat'].value_counts())

# ['TAS-Dep_stat'].count()

# TAS-dep

for sample, df in df_arts_tale_dep.groupby(['<sample>', 'TAS-Dep_stat']):
    print(df.duplicated(subset='region_index').sum())
    # print(df[df.duplicated(subset='region_index')])
    with open(f'art/from_art_{sample[0]}_{sample[1]}.fa', 'wt') as f:
        f.write(
            ''.join(
                df[['region_index', 'align_target_seq']].apply(
                    # lambda x: f'>{x["region_index"]}\n{x["align_target_seq"]}\n', axis=1
                    lambda x: f'{x["align_target_seq"]}\n', axis=1
                ).tolist()
            )
        )


# TAS indep
df_arts[['<sample>', 'TAS-Dep_stat']] = df_arts['file_info'].str.split('/').str[-1].str.replace('.art', '').str.split('_TALE_align.', expand=True)


# for sample, df in df_arts_tale_dep[['<sample>', 'region_index']].groupby('<sample>'):
#     df_art_this_sample = df_arts.query('`<sample>`==@sample')
#     flt = df_art_this_sample.apply(
#         lambda x: True if x['region_index'] not in df_art_this_sample['region_index'] else False,
#         axis=1
#     )
#     df_art_this_sample = df_art_this_sample[flt].copy()


for sample in sort_keys:
    tas_dep_index = sorted(df_arts_tale_dep.query('`<sample>`==@sample')['region_index'].unique().tolist())
    tas_indep_index = sorted(df_arts.query('`<sample>`==@sample').query('region_index not in @tas_dep_index')['region_index'].unique().tolist())
    print(sample, len(tas_dep_index), len(tas_indep_index), len(tas_dep_index) + len(tas_indep_index))
    # DetectSeq_SIRT6-DddA11_REP-1 96 3303 3399
    # DetectSeq_SIRT6-DddA11_REP-2 275 9118 9393
    # DetectSeq_JAK2-DddA11_REP-1 46 775 821
    # DetectSeq_JAK2-DddA11_REP-2 197 560 757
    # DetectSeq_ATP8-DddA11_REP-1 156 59 215
    # DetectSeq_ATP8-DddA6_REP-1 543 229 772
    # DetectSeq_ATP8-DddAwt_REP-1 27 13 40
    
    df_out = df_arts.query('`<sample>`==@sample').query('region_index not in @tas_dep_index')
    
    df_out[['chrom', 'start', 'end']] = df_out['region_index'].str.split('_', expand=True)
    df_out = df_out[['chrom', 'start', 'end', 'region_index', 'align_strand']].copy()
    df_out.insert(4, 'score', '.')
    df_out['start'] = df_out['start'].astype(int) - 30
    df_out['end'] = df_out['end'].astype(int) + 30
    df_out.to_csv(f'art/from_art_putative_IND_{sample}.bed', header=False, index=False, sep='\t')
"""Spyder Project: 3D genome and DdCBE project, analysis for final list.

Created on 2023-04-25

@author: Herman ZHAO

/opt/homebrew/Caskroom/miniconda/base/bin/python
"""
from matplotlib.patches import Rectangle
import matplotlib.pyplot as plt
import collections
import pandas as pd
from glob import glob
import os
import math
from bioat.lib.libcircos import Garc, Gcircle
import collections
import pandas as pd
from glob import glob
import os
import math
from bioat.lib.libcircos import Garc, Gcircle
from bioat.lib.libcolor import plot_colortable
import matplotlib.pyplot as plt
pd.set_option("display.width", 120)  # dataframe宽度
pd.set_option("display.max_columns", None)  # column最大显示数
pd.set_option("display.max_rows", 50)  # row最大显示数

# % set directory
os.chdir("/Volumes/zhaohn_HD/Bio/3.project/2022_DdCBE-3D-Genome_topic/2022-09-30_Detect-seq_batch-1_ATP8_JAK2_SIRT6/")
os.listdir()
colors = ['#64C1E8',
          '#80CED7',
          '#63C7B2',
          '#8E6C88',
          '#CA61C3',
          '#FF958C',
          '#883677']
plot_colortable(colors, ncols=1, labels=[1, 2, 3, 4, 5, 6, 7])
circle = Gcircle()
df_chrom = pd.read_csv("pycircos/project_data/chromosome_length_hg38.csv")
df_chrom = df_chrom[df_chrom['chr'].map(lambda x: x not in ['chrY', 'chrM'])].copy()


for idx, row in df_chrom.iterrows():
    arc = Garc(arc_id=row['chr'], size=row['end'],
               interspace=1, raxis_range=(920, 950), labelposition=40, label_visible=True, facecolor='#FFFFFF')
    circle.add_garc(arc)
circle.set_garcs()
circle.figure
color_dict = {"gneg": "#FFFFFF00", "gpos25": "#EEEEEE", "gpos50": "#BBBBBB", "gpos75": "#777777", "gpos100": "#000000",
              "gvar": "#FFFFFF00", "stalk": "#C01E27", "acen": "#D82322"}

arcdata_dict = collections.defaultdict(dict)
with open("pycircos/project_data/cytoBand_hg38.csv") as f:
    f.readline()
    for line in f:
        line = line.rstrip().split(",")
        name = line[0]
        if name in ['chrY', 'chrM']:
            continue
        start = int(line[1]) - 1
        width = int(line[2]) - (int(line[1]) - 1)
        if name not in arcdata_dict:
            arcdata_dict[name]["positions"] = []
            arcdata_dict[name]["widths"] = []
            arcdata_dict[name]["colors"] = []
        arcdata_dict[name]["positions"].append(start)
        arcdata_dict[name]["widths"].append(width)
        arcdata_dict[name]["colors"].append(color_dict[line[-1]])

for key in arcdata_dict:
    circle.barplot(key, data=[1] * len(arcdata_dict[key]["positions"]), positions=arcdata_dict[key]["positions"],
                   width=arcdata_dict[key]["widths"], raxis_range=[920, 950], facecolor=arcdata_dict[key]["colors"])

circle.figure
df_points = pd.read_csv('final_list_after_igv_check/2023-04-24_merged_final_list_add_header_poisson_result.csv',
                        usecols=['<sample>', 'chr_name', 'region_start', 'region_end', 'treat_mut_count.norm'])
df_points.columns = ['<sample>', 'chr', 'start', 'end', 'value1']


df_points['log10_value'] = df_points['value1'].map(math.log10)


# sort_keys = df_points.groupby('<sample>').count().sort_values(by='chr', ascending=False).index
sort_keys = ['DetectSeq_SIRT6-DddA11_REP-1', 'DetectSeq_SIRT6-DddA11_REP-2',
             'DetectSeq_JAK2-DddA11_REP-1', 'DetectSeq_JAK2-DddA11_REP-2',
             'DetectSeq_ATP8-DddA11_REP-1', 'DetectSeq_ATP8-DddA6_REP-1', 'DetectSeq_ATP8-DddAwt_REP-1']
colors = ['#64C1E8',
          '#80CED7',
          '#5AB4C8',
          '#78C8C8',
          '#FF958C',
          '#D7BFF8',
          '#F8EDD0']
keys_colors = list(zip(sort_keys, colors))
raxis_range = [915, 1035]

for sort_key, color in keys_colors:
    df = df_points.query('`<sample>`==@sort_key')
    df = df.copy()
    
    df['pos'] = raxis_range[1] - raxis_range[0]
    raxis_range[0] = raxis_range[0] - 120
    raxis_range[1] = raxis_range[1] - 120
    print(raxis_range)
    vmin = df['log10_value'].min()
    vmax = df['log10_value'].max()
    
    for idx, point in df_chrom.iterrows():  # 考虑把它放外头
        circle.fillplot(
            point['chr'],
            data=df['pos'],
            # data=[raxis_range[1] - raxis_range[0]],
            rlim=[0, raxis_range[1] - raxis_range[0]],
            raxis_range=raxis_range,
            facecolor=color,
            edgecolor='white'
        )
    
    for chrom, point in df.groupby('chr'):
        # print(point)
        # print(color)
        
        circle.scatterplot(
            chrom,
            data=point['log10_value'],
            positions=(point['start'] + point['end']) / 2,
            rlim=[vmin - 0.05 * abs(vmin), vmax + 0.05 * abs(vmax)],
            raxis_range=raxis_range,
            facecolor="#3B6181",
            # edgecolor='black',
            spine=True,
            markersize=5
        )

circle.figure
circle.figure.savefig("pycircos/project_out.pdf", dpi=300)
df_sort_keys = pd.DataFrame(sort_keys, columns=['<sample>'])
df_sort_values = df_points.groupby('<sample>').count()['chr'].reset_index()
labels = pd.merge(df_sort_keys, df_sort_values).apply(
    lambda x: f'{x["<sample>"]} (n={x["chr"]})', axis=1
)

plot_colortable(colors=colors, ncols=1, labels=labels.tolist())
plt.savefig("pycircos/project_out_legend.pdf")
arts = sorted(glob('art/DetectSeq_*.art'))


ls_arts = []

for art in arts:
    print(art)
    df = pd.read_csv(art, sep='\t')
    df['file_info'] = art
    ls_arts.append(df)

df_arts = pd.concat(ls_arts)
df_arts_tale_dep = (
    df_arts.sort_values(by=['align_total_mismatch', 'align_degen_total_mismatch', 'align_total_gap'])
    .query('align_total_mismatch<=4')
    .query('align_degen_total_mismatch<=4')
    .query('align_total_gap<=2')
)

df_arts_tale_dep.groupby('file_info').describe()[('start', 'count')]


df_arts_tale_dep[['<sample>', 'TAS-Dep_stat']] = (
    df_arts_tale_dep['file_info']
    .str.split('/')
    .str[-1]
    .str.replace('.art', '')
    .str.split('_TALE_align.', expand=True)
)

df_arts_tale_dep.groupby('<sample>')['TAS-Dep_stat'].value_counts()


# print(df_arts_tale_dep.groupby('<sample>')['TAS-Dep_stat'].count())
# print(df_arts_tale_dep.groupby('<sample>')['TAS-Dep_stat'].value_counts())

# ['TAS-Dep_stat'].count()

# TAS-dep

for sample, df in df_arts_tale_dep.groupby(['<sample>', 'TAS-Dep_stat']):
    print(df.duplicated(subset='region_index').sum())
    # print(df[df.duplicated(subset='region_index')])
    with open(f'art/from_art_{sample[0]}_{sample[1]}.fa', 'wt') as f:
        f.write(
            ''.join(
                df[['region_index', 'align_target_seq']].apply(
                    # lambda x: f'>{x["region_index"]}\n{x["align_target_seq"]}\n', axis=1
                    lambda x: f'{x["align_target_seq"]}\n', axis=1
                ).tolist()
            )
        )


# TAS indep
df_arts[['<sample>', 'TAS-Dep_stat']] = df_arts['file_info'].str.split('/').str[-1].str.replace('.art', '').str.split('_TALE_align.', expand=True)


# for sample, df in df_arts_tale_dep[['<sample>', 'region_index']].groupby('<sample>'):
#     df_art_this_sample = df_arts.query('`<sample>`==@sample')
#     flt = df_art_this_sample.apply(
#         lambda x: True if x['region_index'] not in df_art_this_sample['region_index'] else False,
#         axis=1
#     )
#     df_art_this_sample = df_art_this_sample[flt].copy()


for sample in sort_keys:
    tas_dep_index = sorted(df_arts_tale_dep.query('`<sample>`==@sample')['region_index'].unique().tolist())
    tas_indep_index = sorted(df_arts.query('`<sample>`==@sample').query('region_index not in @tas_dep_index')['region_index'].unique().tolist())
    print(sample, len(tas_dep_index), len(tas_indep_index), len(tas_dep_index) + len(tas_indep_index))
    # DetectSeq_SIRT6-DddA11_REP-1 96 3303 3399
    # DetectSeq_SIRT6-DddA11_REP-2 275 9118 9393
    # DetectSeq_JAK2-DddA11_REP-1 46 775 821
    # DetectSeq_JAK2-DddA11_REP-2 197 560 757
    # DetectSeq_ATP8-DddA11_REP-1 156 59 215
    # DetectSeq_ATP8-DddA6_REP-1 543 229 772
    # DetectSeq_ATP8-DddAwt_REP-1 27 13 40
    
    df_out = df_arts.query('`<sample>`==@sample').query('region_index not in @tas_dep_index')
    
    df_out[['chrom', 'start', 'end']] = df_out['region_index'].str.split('_', expand=True)
    df_out = df_out[['chrom', 'start', 'end', 'region_index', 'align_strand']].copy()
    df_out.insert(4, 'score', '.')
    df_out['start'] = df_out['start'].astype(int) - 30
    df_out['end'] = df_out['end'].astype(int) + 30
    df_out.to_csv(f'art/from_art_putative_IND_{sample}.bed', header=False, index=False, sep='\t')
df_out

## ---(Thu May 11 23:07:04 2023)---
import collections
import pandas as pd
from glob import glob
import os
import math
from bioat.lib.libcircos import Garc, Gcircle
from bioat.lib.libcolor import plot_colortable
import matplotlib.pyplot as plt
pd.set_option("display.width", 120)  # dataframe宽度
pd.set_option("display.max_columns", None)  # column最大显示数
pd.set_option("display.max_rows", 50)  # row最大显示数

# % set directory
os.chdir("/Volumes/zhaohn_HD/Bio/3.project/2022_DdCBE-3D-Genome_topic/2022-09-30_Detect-seq_batch-1_ATP8_JAK2_SIRT6/")
os.listdir()
colors = ['#64C1E8',
          '#80CED7',
          '#63C7B2',
          '#8E6C88',
          '#CA61C3',
          '#FF958C',
          '#883677']
plot_colortable(colors, ncols=1, labels=[1, 2, 3, 4, 5, 6, 7])
circle = Gcircle()
df_chrom = pd.read_csv("pycircos/project_data/chromosome_length_hg38.csv")
df_chrom = df_chrom[df_chrom['chr'].map(lambda x: x not in ['chrY', 'chrM'])].copy()


for idx, row in df_chrom.iterrows():
    arc = Garc(arc_id=row['chr'], size=row['end'],
               interspace=1, raxis_range=(920, 950), labelposition=40, label_visible=True, facecolor='#FFFFFF')
    circle.add_garc(arc)
circle.set_garcs()
circle.figure
color_dict = {"gneg": "#FFFFFF00", "gpos25": "#EEEEEE", "gpos50": "#BBBBBB", "gpos75": "#777777", "gpos100": "#000000",
              "gvar": "#FFFFFF00", "stalk": "#C01E27", "acen": "#D82322"}

arcdata_dict = collections.defaultdict(dict)
with open("pycircos/project_data/cytoBand_hg38.csv") as f:
    f.readline()
    for line in f:
        line = line.rstrip().split(",")
        name = line[0]
        if name in ['chrY', 'chrM']:
            continue
        start = int(line[1]) - 1
        width = int(line[2]) - (int(line[1]) - 1)
        if name not in arcdata_dict:
            arcdata_dict[name]["positions"] = []
            arcdata_dict[name]["widths"] = []
            arcdata_dict[name]["colors"] = []
        arcdata_dict[name]["positions"].append(start)
        arcdata_dict[name]["widths"].append(width)
        arcdata_dict[name]["colors"].append(color_dict[line[-1]])

for key in arcdata_dict:
    circle.barplot(key, data=[1] * len(arcdata_dict[key]["positions"]), positions=arcdata_dict[key]["positions"],
                   width=arcdata_dict[key]["widths"], raxis_range=[920, 950], facecolor=arcdata_dict[key]["colors"])

circle.figure
df_points = pd.read_csv('final_list_after_igv_check/2023-04-24_merged_final_list_add_header_poisson_result.csv',
                        usecols=['<sample>', 'chr_name', 'region_start', 'region_end', 'treat_mut_count.norm'])
df_points.columns = ['<sample>', 'chr', 'start', 'end', 'value1']


df_points['log10_value'] = df_points['value1'].map(math.log10)


# sort_keys = df_points.groupby('<sample>').count().sort_values(by='chr', ascending=False).index
sort_keys = ['DetectSeq_SIRT6-DddA11_REP-1', 'DetectSeq_SIRT6-DddA11_REP-2',
             'DetectSeq_JAK2-DddA11_REP-1', 'DetectSeq_JAK2-DddA11_REP-2',
             'DetectSeq_ATP8-DddA11_REP-1', 'DetectSeq_ATP8-DddA6_REP-1', 'DetectSeq_ATP8-DddAwt_REP-1']
colors = ['#64C1E8',
          '#80CED7',
          '#5AB4C8',
          '#78C8C8',
          '#FF958C',
          '#D7BFF8',
          '#F8EDD0']
keys_colors = list(zip(sort_keys, colors))
raxis_range = [915, 1035]

for sort_key, color in keys_colors:
    df = df_points.query('`<sample>`==@sort_key')
    df = df.copy()
    
    df['pos'] = raxis_range[1] - raxis_range[0]
    raxis_range[0] = raxis_range[0] - 120
    raxis_range[1] = raxis_range[1] - 120
    print(raxis_range)
    vmin = df['log10_value'].min()
    vmax = df['log10_value'].max()
    
    for idx, point in df_chrom.iterrows():  # 考虑把它放外头
        circle.fillplot(
            point['chr'],
            data=df['pos'],
            # data=[raxis_range[1] - raxis_range[0]],
            rlim=[0, raxis_range[1] - raxis_range[0]],
            raxis_range=raxis_range,
            facecolor=color,
            edgecolor='white'
        )
    
    for chrom, point in df.groupby('chr'):
        # print(point)
        # print(color)
        
        circle.scatterplot(
            chrom,
            data=point['log10_value'],
            positions=(point['start'] + point['end']) / 2,
            rlim=[vmin - 0.05 * abs(vmin), vmax + 0.05 * abs(vmax)],
            raxis_range=raxis_range,
            facecolor="#3B6181",
            # edgecolor='black',
            spine=True,
            markersize=5
        )

circle.figure
circle.figure.savefig("pycircos/project_out.pdf", dpi=300)
df_sort_keys = pd.DataFrame(sort_keys, columns=['<sample>'])
df_sort_values = df_points.groupby('<sample>').count()['chr'].reset_index()
labels = pd.merge(df_sort_keys, df_sort_values).apply(
    lambda x: f'{x["<sample>"]} (n={x["chr"]})', axis=1
)

plot_colortable(colors=colors, ncols=1, labels=labels.tolist())
plt.savefig("pycircos/project_out_legend.pdf")
arts = sorted(glob('art/DetectSeq_*.art'))


ls_arts = []

for art in arts:
    print(art)
    df = pd.read_csv(art, sep='\t')
    df['file_info'] = art
    ls_arts.append(df)

df_arts = pd.concat(ls_arts)
df_arts_tale_dep = (
    df_arts.sort_values(by=['align_total_mismatch', 'align_degen_total_mismatch', 'align_total_gap'])
    .query('align_total_mismatch<=4')
    .query('align_degen_total_mismatch<=4')
    .query('align_total_gap<=2')
)

df_arts_tale_dep.groupby('file_info').describe()[('start', 'count')]


df_arts_tale_dep[['<sample>', 'TAS-Dep_stat']] = (
    df_arts_tale_dep['file_info']
    .str.split('/')
    .str[-1]
    .str.replace('.art', '')
    .str.split('_TALE_align.', expand=True)
)

df_arts_tale_dep.groupby('<sample>')['TAS-Dep_stat'].value_counts()


# print(df_arts_tale_dep.groupby('<sample>')['TAS-Dep_stat'].count())
# print(df_arts_tale_dep.groupby('<sample>')['TAS-Dep_stat'].value_counts())

# ['TAS-Dep_stat'].count()

# TAS-dep

for sample, df in df_arts_tale_dep.groupby(['<sample>', 'TAS-Dep_stat']):
    print(df.duplicated(subset='region_index').sum())
    # print(df[df.duplicated(subset='region_index')])
    with open(f'art/from_art_{sample[0]}_{sample[1]}.fa', 'wt') as f:
        f.write(
            ''.join(
                df[['region_index', 'align_target_seq']].apply(
                    # lambda x: f'>{x["region_index"]}\n{x["align_target_seq"]}\n', axis=1
                    lambda x: f'{x["align_target_seq"]}\n', axis=1
                ).tolist()
            )
        )


# TAS indep
df_arts[['<sample>', 'TAS-Dep_stat']] = df_arts['file_info'].str.split('/').str[-1].str.replace('.art', '').str.split('_TALE_align.', expand=True)


# for sample, df in df_arts_tale_dep[['<sample>', 'region_index']].groupby('<sample>'):
#     df_art_this_sample = df_arts.query('`<sample>`==@sample')
#     flt = df_art_this_sample.apply(
#         lambda x: True if x['region_index'] not in df_art_this_sample['region_index'] else False,
#         axis=1
#     )
#     df_art_this_sample = df_art_this_sample[flt].copy()


for sample in sort_keys:
    tas_dep_index = sorted(df_arts_tale_dep.query('`<sample>`==@sample')['region_index'].unique().tolist())
    tas_indep_index = sorted(df_arts.query('`<sample>`==@sample').query('region_index not in @tas_dep_index')['region_index'].unique().tolist())
    print(sample, len(tas_dep_index), len(tas_indep_index), len(tas_dep_index) + len(tas_indep_index))
    # DetectSeq_SIRT6-DddA11_REP-1 96 3303 3399
    # DetectSeq_SIRT6-DddA11_REP-2 275 9118 9393
    # DetectSeq_JAK2-DddA11_REP-1 46 775 821
    # DetectSeq_JAK2-DddA11_REP-2 197 560 757
    # DetectSeq_ATP8-DddA11_REP-1 156 59 215
    # DetectSeq_ATP8-DddA6_REP-1 543 229 772
    # DetectSeq_ATP8-DddAwt_REP-1 27 13 40
    
    df_out = df_arts.query('`<sample>`==@sample').query('region_index not in @tas_dep_index')
    
    df_out[['chrom', 'start', 'end']] = df_out['region_index'].str.split('_', expand=True)
    df_out = df_out[['chrom', 'start', 'end', 'region_index', 'align_strand']].copy()
    df_out.insert(4, 'score', '.')
    df_out['start'] = df_out['start'].astype(int) - 30
    df_out['end'] = df_out['end'].astype(int) + 30
    df_out.to_csv(f'art/from_art_putative_IND_{sample}.bed', header=False, index=False, sep='\t')

## ---(Fri Aug  4 20:35:45 2023)---
pwd
which conda
!which conda
conda env list
!conda env list
!which python
!which pip

## ---(Fri Aug  4 20:47:51 2023)---
ls