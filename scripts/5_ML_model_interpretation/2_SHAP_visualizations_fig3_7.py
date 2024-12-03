
import shap 
import pandas as pd
import numpy as np
import matplotlib.pyplot as pltplo
 

shap_values = pd.read_csv("2022_09_26_shap_matrix_colnames.csv", header=0, index_col=0)
data = pd.read_csv("2022_09_26_BD_colnames.csv", header=0, index_col=0)


shap_values = pd.read_csv("2022_08_11_shap_values_matrix_YesIR.csv", header=0, index_col=0)
data = pd.read_csv("2022_08_11_BD_YesIR.csv", header=0, index_col=0)

shap_values = pd.read_csv("2022_08_11_shap_values_matrix_NoIR.csv", header=0, index_col=0)
data = pd.read_csv("2022_08_11_BD_NoIR.csv", header=0, index_col=0)


shap_values = pd.read_csv("./2024_01_15_shap_values_examples_excluided_by_undersampling.csv", header=0, index_col=0)
data = pd.read_csv("2024_01_15_BD_examples_excluided_by_undersampling.csv", header=0, index_col=0)

shap_values = pd.read_csv("./2024_01_15_shap_values_examples_excluided_by_undersampling_missclassified.csv", header=0, index_col=0)
data = pd.read_csv("2024_01_15_BD_examples_excluided_by_undersampling_missclassified.csv", header=0, index_col=0)

data = data.iloc[:, 0:301 ]
features_names = list(data.columns)

shap_values.index
# Index(['R24959', 'R39751', 'R94897', 'S58671', 'S69608', 'S75679', 'S825037',
#        'S85555', 'Z091_1'],
#       dtype='object')

# Index(['R24959', 'R39751', 'R94897', 'S18312', 'S28967', 'S40754', 'S40755',
#        'S43130', 'S50050', 'S54613', 'S58671', 'S60829', 'S66605', 'S67718',
#        'S69608', 'S70326', 'S74848', 'S75679', 'S81492', 'S825037', 'S85555',
#        'Z004-2', 'Z010-2', 'Z013-2', 'Z014-2', 'Z021-2', 'Z032-1', 'Z041-2',
#        'Z044-2', 'Z074-2', 'Z091-1', 'Z102-1', 'Z112-1', 'Z120-2', 'Z127-1',
#        'Z137-2', 'Z140-2', 'Z160-2'],
#       dtype='object')

shap_values = shap_values.to_numpy()
data = data.to_numpy()

base_value = np.array([0.5])



shap.summary_plot(shap_values, data, plot_type="bar", feature_names= features_names)

shap.summary_plot(shap_values, data, plot_type="dot", feature_names= features_names)

shap.summary_plot(shap_values, data, plot_type="violin", feature_names= features_names)

plot = shap.force_plot(base_value, shap_values, data, feature_names= features_names)


# shap.save_html('my_force_plot.html', plot)
# shap.save_html('my_force_plot_undersampling.html', plot)
# shap.save_html('my_force_plot_missclassified.html', plot)

# Index(['R24959', 'R39751', 'R94897', 'S58671', 'S69608', 'S75679', 'S825037',
#        'S85555', 'Z091_1'],
#       dtype='object')


shap.force_plot(base_value, shap_values[0,:], #data[0, :]
feature_names= features_names, matplotlib=True, contribution_threshold=0.02)


shap.force_plot(base_value, shap_values[5,:], #data[5, :]
feature_names= features_names, matplotlib=True, contribution_threshold=0.02)

shap.force_plot(base_value, shap_values[9,:], #data[5, :]
feature_names= features_names, matplotlib=True, contribution_threshold=0.02)


# BD_NOIR YESIR

shap.force_plot(base_value, shap_values[0,:], feature_names= features_names, matplotlib=True, contribution_threshold=0.02)

shap.force_plot(base_value, shap_values[1,:], feature_names= features_names, matplotlib=True, contribution_threshold=0.02)

shap.force_plot(base_value, shap_values[2,:], feature_names= features_names, matplotlib=True, contribution_threshold=0.02)

shap.force_plot(base_value, shap_values[3,:], feature_names= features_names, matplotlib=True, contribution_threshold=0.02)

shap.force_plot(base_value, shap_values[4,:], feature_names= features_names, matplotlib=True, contribution_threshold=0.02)

shap.force_plot(base_value, shap_values[5,:], feature_names= features_names, matplotlib=True, contribution_threshold=0.02)

shap.force_plot(base_value, shap_values[6,:], feature_names= features_names, matplotlib=True, contribution_threshold=0.02)

shap.force_plot(base_value, shap_values[7,:], feature_names= features_names, matplotlib=True, contribution_threshold=0.02)

shap.force_plot(base_value, shap_values[8,:], feature_names= features_names, matplotlib=True, contribution_threshold=0.02)

shap.force_plot(base_value, shap_values[9,:], feature_names= features_names, matplotlib=True, contribution_threshold=0.02)

shap.force_plot(base_value, shap_values[10,:], feature_names= features_names, matplotlib=True, contribution_threshold=0.02)

shap.force_plot(base_value, shap_values[11,:], feature_names= features_names, matplotlib=True, contribution_threshold=0.02)


shap.force_plot(base_value, shap_values[12,:], feature_names= features_names, matplotlib=True, contribution_threshold=0.02)

shap.force_plot(base_value, shap_values[13,:], feature_names= features_names, matplotlib=True, contribution_threshold=0.02)

shap.force_plot(base_value, shap_values[14,:], feature_names= features_names, matplotlib=True, contribution_threshold=0.02)

shap.force_plot(base_value, shap_values[15,:], feature_names= features_names, matplotlib=True, contribution_threshold=0.02)

shap.force_plot(base_value, shap_values[16,:], feature_names= features_names, matplotlib=True, contribution_threshold=0.02)

shap.force_plot(base_value, shap_values[17,:], feature_names= features_names, matplotlib=True, contribution_threshold=0.02)

shap.force_plot(base_value, shap_values[18,:], feature_names= features_names, matplotlib=True, contribution_threshold=0.02)

shap.force_plot(base_value, shap_values[19,:], feature_names= features_names, matplotlib=True, contribution_threshold=0.02)


shap.force_plot(base_value, shap_values[20,:], feature_names= features_names, matplotlib=True, contribution_threshold=0.02)

shap.force_plot(base_value, shap_values[21,:], feature_names= features_names, matplotlib=True, contribution_threshold=0.02)

shap.force_plot(base_value, shap_values[22,:], feature_names= features_names, matplotlib=True, contribution_threshold=0.02)

shap.force_plot(base_value, shap_values[23,:], feature_names= features_names, matplotlib=True, contribution_threshold=0.02)

shap.force_plot(base_value, shap_values[24,:], feature_names= features_names, matplotlib=True, contribution_threshold=0.02)

shap.force_plot(base_value, shap_values[25,:], feature_names= features_names, matplotlib=True, contribution_threshold=0.02)




