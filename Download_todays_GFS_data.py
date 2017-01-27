
# coding: utf-8

# In[111]:

# download today's GFS forecast from 00hrs
import time 
time_list = ["000", "006", "012", "018"]
forecast_time = (time.strftime("%Y%m%d") + str("00"))
url_list = []

# make dates for the GFS download loop
for hr in time_list:
    gfs_url = str("ftp://ftpprd.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs." + 
                  forecast_time + "/gfs.t00z.pgrb2.0p50.f" + hr)
    url_list.append(gfs_url) 


# In[140]:

# download the GFS data in the list
import os
for url in url_list:
    cmd3 = str('wget -nc ' + url)
    os.system(cmd3)


# In[ ]:




# In[ ]:



