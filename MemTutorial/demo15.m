% MemToolbox demo 15: Customizing plots and figures
clear all;
data = MemDataset(1);
figHand = PlotData(data);
subfigure(2,2,1,figHand);
