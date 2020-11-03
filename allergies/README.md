## Data Sources and Considerations

[Link to website](https://vastava.github.io/allergies/)
1. Daily Temperature data (via [NOAA API](https://www.ncdc.noaa.gov/cdo-web/webservices/v2)): 
	* Daily minTemp data was collected for each city from 1950-2020
	* Seasons were classified using the following definitions:
		* Spring = Months 3-5
		* Summer = Months 6-8
		* Fall = Months 9-11
		* Winter = Months 12-2
	* “Frost season” length was calculated by determining the difference between the first day in fall and last day in spring with temperature <= 32°F; “Growing season” length was calculated by subtracting “Frost Season” from 365
	* 1995 Stockton, and several years in McAllen had no days in which the temperature was <= 32°F; these years were given a “growing season” value of 365

2. Practicing allergist data (via [Medicare Provider Utilization data](https://data.cms.gov/use-agreement?id=fs4p-t5eq&name=Medicare%20Provider%20Utilization%20and%20Payment%20Data:%20Physician%20and%20Other%20Supplier%20PUF%20CY2017))
	* Provider practice data filtered by whether or not provider is an allergist
	* Used address to determine which county provider practices in
	* CMS data was joined with census population estimates to determine number of allergists per 100k people in county

3. Air pollution data (via [CACES](https://www.caces.us/data))
	* particulate matter (≤2.5 μm)
	* concentrations are listed as the variable "pred_weight"; units are micrograms per cubic meter for PM2.5
	* Data available from 1999-2015

4. Asthma prevalence data (via [CDC](https://www.cdc.gov/asthma/Asthma_Prevalence_in_US.pptx))
	* Asthma prevalence data are self-reported by respondents to the National Health Interview Survey (NHIS). 
	* From 1997-2000, a redesign of the NHIS questions resulted in a break in the trend data as the new questions were not fully comparable to the previous questions. Data exists for 1980-96 and 2001-18.
	* 1980-96 source: Moorman JE, Akinbami LJ, Bailey CM, et al. National Surveillance of Asthma: United States, 2001 -2010. National Center for Health Statistics. Vital Health Stat 3 (35). 2012.
	* 2001-18 source: [NHIS prevalence tables](https://www.cdc.gov/asthma/nhis/default.htm#anchor_1524067853614)

5. Ranking of most challenging places to live for people with allergies (via [AAFA 2020 report](https://www.aafa.org/media/2608/aafa-2020-allergy-capitals-report.pdf))
