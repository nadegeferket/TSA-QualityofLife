# Quality of Life in Flanders: a Comparative Study Using Twitter and Survey Data
In this repository, the code implementation can be found of the KU Leuven Master's Thesis "Quality of Life in Flanders: a Comparative Study Using Twitter and Survey Data", written by Sarah Vranken and Nadège Ferket in the academic year 2022-2023, and under the supervision of Manon Reusens and Prof. Dr. Bart Baesens. The project was conducted in partnership with Statistics Flanders, represented by Dr. Michael Reusens. This dissertation investigates the use of social media data - Twitter data in particular - as a proxy and/or complement to survey data. Twitter data, containing perceptions on Quality of Life, is held next to multiple surveys examining the Quality of Life of the Flemish population. Quality of Life (QoL) is divided into three domains: personal well-being, social well-being, and well-being at work, which are further split up into eight specific subdomains. 

![image](https://github.com/nadegeferket/TSA-QualityofLife/assets/116740372/1451263d-e595-4fe2-b298-de690c77afa3)

Each year, multiple surveys are sent out to Flemish citizens in order to measure perspectives on their Quality of Life. However, drawing results solely from these surveys may give limited insights compared to the conclusions that can be made when combining this data source with social media data. By giving insights into the usage of social media data to capture citizens’ perceptions about their life, official statistics can be complemented with this found data source. This is a pressing matter because of the declining response rate, time intensity, and both response burden and bias of surveys. Furthermore, social media is able to provide perceptions unobtainable from survey data, like monitoring changes in the public opinion, indicating issue salience or capturing respondents for rare events. 

## Data Collection 
The following code snippet allows you to collect your own dataset per region and year using the Full-Archive Search API of Twitter. A bearer token provided by [Twitter](https://developer.twitter.com/en/products/twitter-api/academic-research) is needed in order to run the code below. More details on the code can be found on [this article](https://towardsdatascience.com/an-extensive-guide-to-collecting-tweets-from-twitter-api-v2-for-academic-research-using-python-3-518fcb71df2a), which provides an extensive step-by-step process for collecting Tweets. For each QoL subdomain, 10-15 keywords are defined in order to collect enough and accurate tweets for this research. These dictionaries are manually formultaed, based on a [QoL study](https://www.who.int/tools/whoqol/whoqol-100/docs/default-source/publishing-policies/whoqol/dutch-netherlands-whoqol-100) by the World Health Organization.
```python

import pandas
dl = DataLoader(bearer_token)   

#Retrieve around 200 tweets, 100 on 2020/01/01 and 100 on 2020/01/02, written in English
tweet_list = dl.retrieve_tweet(start_list=['2017-01-01T00:00:00.000Z','2017-02-01T00:00:00.000Z',
                                          '2017-03-01T00:00:00.000Z','2017-04-01T00:00:00.000Z',
                                          '2017-05-01T00:00:00.000Z','2017-06-01T00:00:00.000Z',
                                          '2017-07-01T00:00:00.000Z','2017-08-01T00:00:00.000Z',
                                          '2017-09-01T00:00:00.000Z','2017-10-01T00:00:00.000Z',
                                          '2017-11-01T00:00:00.000Z','2017-12-01T00:00:00.000Z'],
                               end_list=['2017-01-31T00:00:00.000Z','2017-02-28T00:00:00.000Z',
                                        '2017-03-31T00:00:00.000Z','2017-04-30T00:00:00.000Z',
                                        '2017-05-31T00:00:00.000Z','2017-06-30T00:00:00.000Z',
                                        '2017-07-31T00:00:00.000Z','2017-08-31T00:00:00.000Z',
                                        '2017-09-30T00:00:00.000Z','2017-10-31T00:00:00.000Z',
                                        '2017-11-30T00:00:00.000Z','2017-12-31T00:00:00.000Z'],
                                keyword="mindfulness place_country:BE has:geo lang:nl",
                               tweet_per_period=100, 
                               )
                               
#Convert the Twitter json output to csv  and save files 

tweet, user = dl.to_dataframe(tweet_list)
tweet.to_csv('tweet_info2017mindfulness.csv')
user.to_csv('user_info2017mindfulness.csv')

#Divide the data into 5 different files according to Flemish region and all of its subregions in the Flemish_regions file (French equivalents also added)

df_provincie = pd.read_csv("Flemish_regions.csv")
provincieNamen = ["Limburg","Antwerpen","Vlaams_Brabant","West_Vlaanderen","Oost_Vlaanderen"]
steden_per_provincie = [df_provincie[s] for s in provincieNamen]
for i in tqdm(range(0,len(steden_per_provincie))):
    rslt_df = tweet[tweet['location_geo'].isin(steden_per_provincie[i])]
    rslt_df.to_csv("tweet_per_provincie_" + provincieNamen[i] + "famleden" + ".csv")

```
## Data Classification
For the classification of the sentiment the collected tweets are containing, [the 'vlaams-twitter-sentiment-model'](https://github.com/vsa-datascience/vlaams-twitter-sentiment-model) of Statistics Flanders is used. Small steps of pre-processing are added in order to eliminate errors in the process. 
```python

from twitter_sentiment_classifier import batch_predict

import pandas
data = pandas.read_csv('Downloads\\tweet_per_provincie_welvarendOost_Vlaanderen.csv') #geef eigen doc in
texts = data['text']
lijst = list(texts)
for i in range(0,len(texts)):
    #preprocessing stap: errors elimineren
    lijst[i] = lijst[i].replace("\n"," ")
    lijst[i] = lijst[i].replace("\t"," ")
    lijst[i] = lijst[i].replace("\r"," ")
    
batch_predict(lijst) 
```

## Subjective Well-Being
Once the classification is done, these findings are used to formulate a Subjective Well-Being (SWB) measure. For this the multiple papers Iacus wrote about QoL are followed. His [code](https://github.com/siacus), however, is in R rather than Python as the rest of the research is. Therefore, notebooks are created based on [the Subjective Well-Being Index](https://sciendo.com/article/10.2478/jos-2020-0017) (Iacus et al., 2020).

All sentiments of one region and domain is being merged and used in a calculation in order to derive the SWB index, for example, for the region Antwerp and the subdomain Emotional well-being:
```python
import pandas as pd

df = pd.read_excel(r'C:\Users\vrank\emotionalwellbeing_Antwerpen_2018\sentiment\sentiment_depressie_Antw.xlsx')
df1 = pd.read_excel(r'C:\Users\vrank\emotionalwellbeing_Antwerpen_2018\sentiment\sentiment_droevig_Antw.xlsx')
df2 = pd.read_excel(r'C:\Users\vrank\emotionalwellbeing_Antwerpen_2018\sentiment\sentiment_eenzaam_Antw.xlsx')
df3 = pd.read_excel(r'C:\Users\vrank\emotionalwellbeing_Antwerpen_2018\sentiment\sentiment_gelukkig_Antw.xlsx')
df4 = pd.read_excel(r'C:\Users\vrank\emotionalwellbeing_Antwerpen_2018\sentiment\sentiment_gevoelens_Antw.xlsx')
df5 = pd.read_excel(r'C:\Users\vrank\emotionalwellbeing_Antwerpen_2018\sentiment\sentiment_hoopvol_Antw.xlsx')
df6 = pd.read_excel(r'C:\Users\vrank\emotionalwellbeing_Antwerpen_2018\sentiment\sentiment_somber_Antw.xlsx')
df7 = pd.read_excel(r'C:\Users\vrank\emotionalwellbeing_Antwerpen_2018\sentiment\sentiment_tevreden_Antw.xlsx')
df8 = pd.read_excel(r'C:\Users\vrank\emotionalwellbeing_Antwerpen_2018\sentiment\sentiment_veerkracht_Antw.xlsx')
df9 = pd.read_excel(r'C:\Users\vrank\emotionalwellbeing_Antwerpen_2018\sentiment\sentiment_vreugde_Antw.xlsx')
df10 = pd.read_excel(r'C:\Users\vrank\emotionalwellbeing_Antwerpen_2018\sentiment\sentiment_wanhoop_Antw.xlsx')
```
```python

list0 = df.values.tolist()
list1 = df1.values.tolist()
list2 = df2.values.tolist()
list3 = df3.values.tolist()
list4 = df4.values.tolist()
list5 = df5.values.tolist()
list6 = df6.values.tolist()
list7 = df7.values.tolist()
list8 = df8.values.tolist()
list9 = df9.values.tolist()
list10 = df10.values.tolist()
listmax=list0+list1+list2+list3+list4+list5+list6+list7+list8+list9+list10
```
```python
out = []
for sublist in listmax:
    out.extend(sublist)
    
out

pos= out.count('POSITIVE')
neg= out.count('NEGATIVE')
neu= out.count('NEUTRAL')

percentpos= pos/len(out)
percentneg= neg/len(out)

SWBI= percentpos/(percentpos+percentneg)
```
## Selection Bias
Selection bias occurs when the data used to make conclusions is not chosen randomly, leading to distortion in the data. Selection bias, also referred to as topic bias,
includes selection-on-outcome bias, negativity bias, and keyword bias. [Selection-on-outcome-bias](https://dl.acm.org/doi/10.1145/3185048) occurs because people discussing a rare event are more likely to discuss event-related topics beforehand and in this way can self-select themselves into the panel. [Negativity bias](https://www.tandfonline.com/doi/full/10.1080/19331681.2015.1100225) stems from people putting more emphasis on negative events. Keyword bias is a new type of bias introduced in QoL research by this paper. The use of keywords in conducting Twitter research to gauge Subjective Well-Being may lead to bias if there is an increase in positively perceived keywords. For the case study of Flanders, the effect of a change of keywords in the most negatively preceived QoL domains is investigated. One of those domains accepted the null hypothesis of the Wilcoxon signed rank test afterwards, indicating that the results from Twitter data reflect the SCV survey results. This domain underwent a significant change in SWB from addapting four keywords, which proves the importance of keyword selection.

![keyword bias picture](https://github.com/nadegeferket/TSA-QualityofLife/assets/116740372/c5314649-9986-456e-817a-fb9bd1e64c60 | "width="300" height="200")


## Sampling bias
Sampling bias occurs when the sample of data used to make conclusions is not representative of the entire population. The Twitter user’s characteristics cannot be assumed to match the population’s characteristics, inferring demographic bias. In the case study of Flanders, post-stratification is carried out by reweighting the Twitter corpus to the underlying tweeting population. By normalizing the SWB results by [the Odds ratio](https://link.springer.com/article/10.1007/s10708-018-9960-6) (Zivanovic et al., 2020), more robust SWB results are obtained. In this research, demographic bias is applied to location, but the same mitigation technique can be used for age, gender, or other demographic variables.


## Migration Bias
Migration bias occurs because this research relies on geo-tagged tweets. The discussion can arise that a person sending a message present in a region in Flanders is not necessarily living in that region, but the residence is work or travel related instead. A proposal to mitigate this type of bias is given in this research: [the modal tweet method] (https://epjdatascience.springeropen.com/articles/10.1140/epjds/s13688-020-00254-7) (Armstrong et al.,2021). For the case study of Flanders, the location history of a set of 442 users is extracted and examined. These users are then categorized in 5 different types:
![image](https://github.com/nadegeferket/TSA-QualityofLife/assets/116740372/b1a6f2cf-79da-4d86-8e75-6b40b7348fea)

The following code retrieves the location history of a given user and divides the years 2014-2018 into 20 different subsets, with time intervals of 3 months.
```python
from datetime import datetime
dl = DataLoader(bearer_token)   

#Retrieve around 200 tweets, 100 on 2020/01/01 and 100 on 2020/01/02, written in English
tweet_list = dl.retrieve_tweet(start_list=['2014-01-01T00:00:00.000Z','2014-02-01T00:00:00.000Z',
                                          '2014-03-01T00:00:00.000Z','2014-04-01T00:00:00.000Z',
                                          '2014-05-01T00:00:00.000Z','2014-06-01T00:00:00.000Z',
                                          '2014-07-01T00:00:00.000Z','2014-08-01T00:00:00.000Z',
                                          '2014-09-01T00:00:00.000Z','2014-10-01T00:00:00.000Z',
                                          '2014-11-01T00:00:00.000Z','2014-12-01T00:00:00.000Z',
                                           
                                          '2015-01-01T00:00:00.000Z','2015-02-01T00:00:00.000Z',
                                          '2015-03-01T00:00:00.000Z','2015-04-01T00:00:00.000Z',
                                          '2015-05-01T00:00:00.000Z','2015-06-01T00:00:00.000Z',
                                          '2015-07-01T00:00:00.000Z','2015-08-01T00:00:00.000Z',
                                          '2015-09-01T00:00:00.000Z','2015-10-01T00:00:00.000Z',
                                          '2015-11-01T00:00:00.000Z','2015-12-01T00:00:00.000Z',
                                           
                                          '2016-01-01T00:00:00.000Z','2016-02-01T00:00:00.000Z',
                                          '2016-03-01T00:00:00.000Z','2016-04-01T00:00:00.000Z',
                                          '2016-05-01T00:00:00.000Z','2016-06-01T00:00:00.000Z',
                                          '2016-07-01T00:00:00.000Z','2016-08-01T00:00:00.000Z',
                                          '2016-09-01T00:00:00.000Z','2016-10-01T00:00:00.000Z',
                                          '2016-11-01T00:00:00.000Z','2016-12-01T00:00:00.000Z',
                                           
                                          '2017-01-01T00:00:00.000Z','2017-02-01T00:00:00.000Z',
                                          '2017-03-01T00:00:00.000Z','2017-04-01T00:00:00.000Z',
                                          '2017-05-01T00:00:00.000Z','2017-06-01T00:00:00.000Z',
                                          '2017-07-01T00:00:00.000Z','2017-08-01T00:00:00.000Z',
                                          '2017-09-01T00:00:00.000Z','2017-10-01T00:00:00.000Z',
                                          '2017-11-01T00:00:00.000Z','2017-12-01T00:00:00.000Z',
                                          '2018-01-01T00:00:00.000Z','2018-02-01T00:00:00.000Z',
                                          '2018-03-01T00:00:00.000Z','2018-04-01T00:00:00.000Z',
                                          '2018-05-01T00:00:00.000Z','2018-06-01T00:00:00.000Z',
                                          '2018-07-01T00:00:00.000Z','2018-08-01T00:00:00.000Z',
                                          '2018-09-01T00:00:00.000Z','2018-10-01T00:00:00.000Z',
                                          '2018-11-01T00:00:00.000Z','2018-12-01T00:00:00.000Z'],
                               
                               end_list=['2014-01-31T00:00:00.000Z','2014-02-28T00:00:00.000Z',
                                        '2014-03-31T00:00:00.000Z','2014-04-30T00:00:00.000Z',
                                        '2014-05-31T00:00:00.000Z','2014-06-30T00:00:00.000Z',
                                        '2014-07-31T00:00:00.000Z','2014-08-31T00:00:00.000Z',
                                        '2014-09-30T00:00:00.000Z','2014-10-31T00:00:00.000Z',
                                        '2014-11-30T00:00:00.000Z','2014-12-31T00:00:00.000Z',
                                        
                                        '2015-01-31T00:00:00.000Z','2015-02-28T00:00:00.000Z',
                                        '2015-03-31T00:00:00.000Z','2015-04-30T00:00:00.000Z',
                                        '2015-05-31T00:00:00.000Z','2015-06-30T00:00:00.000Z',
                                        '2015-07-31T00:00:00.000Z','2015-08-31T00:00:00.000Z',
                                        '2015-09-30T00:00:00.000Z','2015-10-31T00:00:00.000Z',
                                        '2015-11-30T00:00:00.000Z','2015-12-31T00:00:00.000Z',
                                        '2016-01-31T00:00:00.000Z','2016-02-29T00:00:00.000Z',
                                        '2016-03-31T00:00:00.000Z','2016-04-30T00:00:00.000Z',
                                        '2016-05-31T00:00:00.000Z','2016-06-30T00:00:00.000Z',
                                        '2016-07-31T00:00:00.000Z','2016-08-31T00:00:00.000Z',
                                        '2016-09-30T00:00:00.000Z','2016-10-31T00:00:00.000Z',
                                        '2016-11-30T00:00:00.000Z','2016-12-31T00:00:00.000Z',
                                        
                                        '2017-01-31T00:00:00.000Z','2017-02-28T00:00:00.000Z',
                                        '2017-03-31T00:00:00.000Z','2017-04-30T00:00:00.000Z',
                                        '2017-05-31T00:00:00.000Z','2017-06-30T00:00:00.000Z',
                                        '2017-07-31T00:00:00.000Z','2017-08-31T00:00:00.000Z',
                                        '2017-09-30T00:00:00.000Z','2017-10-31T00:00:00.000Z',
                                        '2017-11-30T00:00:00.000Z','2017-12-31T00:00:00.000Z',
                                        
                                        '2018-01-31T00:00:00.000Z','2018-02-28T00:00:00.000Z',
                                        '2018-03-31T00:00:00.000Z','2018-04-30T00:00:00.000Z',
                                        '2018-05-31T00:00:00.000Z','2018-06-30T00:00:00.000Z',
                                        '2018-07-31T00:00:00.000Z','2018-08-31T00:00:00.000Z',
                                        '2018-09-30T00:00:00.000Z','2018-10-31T00:00:00.000Z',
                                        '2018-11-30T00:00:00.000Z','2018-12-31T00:00:00.000Z'],
                                         keyword= "has:geo lang:nl from: 5799162",
                               tweet_per_period=10)
                               
#Convert the Twitter json output to csv  and save files                             
tweet, user = dl.to_dataframe(tweet_list)
geo_info = pd.DataFrame({"datum" : tweet["created_at"], "plaats": tweet["location_geo"]})
data_lijst = geo_info["datum"].tolist()
plaats_lijst = geo_info["plaats"].tolist()
res = [[] for i in range(1,21)]
for i in range(0,len(data_lijst)):
        d = data_lijst[i]
        jaar = d.year - 2010
        maand = d.month
        ip = (maand - 1)//3 + 1
        p = 4*jaar - 15 
        kolom = p + ip - 2
        res[kolom].append(plaats_lijst[i])
        for i in range(0,20):
    res[i].sort()
    loc_lijst = list(set(res[i]))
    extra = [(l,res[i].count(l)) for l in loc_lijst]
    extra.sort(key = lambda x: x[1])
    res[i].extend(extra)
        
g = max(len(res[i]) for i in range(0,20))
for i in range(0,20):  
    laatste = len(res[i])
    v = g - len(res[i])
    for j in range(0,v): 
        res[i].append(" ") 
    res[i].append("FINAL")
    res[i].append(res[i][laatste-1][0].upper())
    
iks = {"periode 1" : res[0],
       "periode 2" : res[1],
       "periode 3" : res[2],
       "periode 4" : res[3],
       "periode 5" : res[4],
       "periode 6" : res[5],
       "periode 7" : res[6],
       "periode 8" : res[7],
       "periode 9" : res[8],
       "periode 10" : res[9],
       "periode 11" : res[10],
       "periode 12" : res[11],
       "periode 13" : res[12],
       "periode 14" : res[13],
       "periode 15" : res[14],
       "periode 16" : res[15],
       "periode 17" : res[16],
       "periode 18" : res[17],
       "periode 19" : res[18],
       "periode 20" : res[19]
      }

    
migration_info = pd.DataFrame(iks) 
    
tweet.to_csv('C:\\Users\\nadeg\\OneDrive\\Documenten\\uitvoerbestanden\\tweet_output_path.csv')
user.to_csv('C:\\Users\\nadeg\\OneDrive\\Documenten\\uitvoerbestanden\\user_output_path.csv')
migration_info.to_csv('C:\\Users\\nadeg\\OneDrive\\Documenten\\uitvoerbestanden\\migration_output_path.csv')

```
## Contact
Nadège Ferket nadegeferket@hotmail.com ; Sarah Vranken vranken.sarah@hotmail.com
```
