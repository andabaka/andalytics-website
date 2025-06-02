---
title: "Drought Stress in Forests: Mastering the SPEI Package for Climate Analysis"
author: "Marijana Andabaka"
date: "2025-06-02"
slug: "spei-drought-analysis-forests"
categories: ["R", "Forest Research", "Climate Analysis", "Drought Monitoring"]
tags: ["SPEI", "drought index", "climate analysis", "forest stress", "evapotranspiration", "R", "forest science", "climate change", "precipitation", "temperature", "forest management", "ecological modeling", "time series analysis", "climate data"]
summary: "Master forest drought analysis with the SPEI package - detect drought stress months before visible symptoms and create standardized assessments across multiple ecological time scales."
description: "A comprehensive tutorial on implementing drought stress analysis in forest research using the SPEI (Standardized Precipitation-Evapotranspiration Index) package in R. Learn to calculate multi-temporal drought indices, create publication-ready visualizations, and connect drought patterns to forest health outcomes for climate-smart forest management."
layout: rmarkdown
imageAttribution: 'Photo by <a href="https://unsplash.com/@bogomil" target="_blank">Bogomil Mihaylov</a> on <a href="https://unsplash.com" target="_blank">Unsplash</a>'
---

      




## Are you still using rainfall totals to assess forest drought risk?

But what if I told you that you could:

• **Detect drought stress months before visible symptoms appear** ⏱️  
• **Quantify drought impacts across multiple ecological time scales** 🌲  
• **Create standardized assessments comparable across forest regions** 📊  
• **Generate publication-ready visualizations with minimal code** ✅  

<br>

Quantifying drought stress has become absolutely critical for forest research in today's climate-changing world. The Standardized Precipitation-Evapotranspiration Index (SPEI) provides a sophisticated framework that separates basic drought monitoring from truly actionable insights.

This tutorial demonstrates a complete SPEI analysis workflow, taking you from raw climate data to publication-ready drought visualizations that reveal patterns invisible to traditional methods.

Let's explore how the SPEI package delivers insight into drought patterns affecting forest ecosystems.

<br>

## Why Traditional Drought Monitoring Falls Short

Here's the typical forest researcher approach to drought assessment:

- **Rainfall-only analysis** - Focus solely on precipitation totals
- **Single time scale** - Miss complex ecological response patterns  
- **Regional inconsistency** - No standardized comparison method
- **Temperature blindness** - Ignore evapotranspiration effects

But here's what changes everything: The SPEI package provides a comprehensive drought assessment that accounts for both precipitation inputs and atmospheric water demand.

<br>

## The SPEI Advantage for Forest Research

The SPEI index, developed by Vicente-Serrano et al. (2010), addresses critical limitations in traditional drought indices by incorporating both precipitation and temperature effects on evapotranspiration.SPEI values are standardized with a mean of 0 and standard deviation of 1, typically ranging from -3 to +3, where negative values indicate drought conditions (SPEI < -1.0 = moderate drought, < -1.5 = severe drought, < -2.0 = extreme drought) and positive values represent wet conditions.

<br>

### How SPEI Outperforms Other Drought Indices

🟢 Compared to Palmer Drought Severity Index (PDSI), SPEI uses standardized values (comparable across regions) vs. PDSI's location-specific values. SPEI offers flexible time scales vs. PDSI's fixed ~9-month scale, and SPEI has simpler calculation requirements, and faster computation.

🟢 Compared to Standardized Precipitation Index (SPI), SPEI includes temperature effects on evapotranspiration vs. SPI's precipitation-only approach. SPEI better captures drought intensity under warming conditions, and provides more accurate forest stress assessment in changing climates.

<br>

### Multi-temporal Analysis: Matching Drought Scales to Forest Processes

This is where SPEI becomes truly powerful for forest research - different time scales capture distinct ecological responses:

- 1-Month SPEI: Immediate Physiological Responses

Represents water balance over the current month capturing acute drought stress and immediate tree responses.

- 6-Month SPEI: Seasonal Growth Impacts

Integrates water balance over the past 6 months (current growing season) reflecting seasonal drought effects on annual growth, ring formation, and reproduction.

- 12-Month SPEI: Annual Stress Patterns

Accumulates water balance over 12 months (full annual cycle) showing moderate-term drought impacts on crown condition and tree vigor. Key indicator for forest health assessments and management decisions.

- 24-Month SPEI: Long-term Drought Conditions

Represents cumulative water balance over 2 years identifying chronic drought stress leading to mortality and ecosystem changes.

<br>

### Key Technical Advantages

- Temperature Sensitivity: Accounts for increased evapotranspiration in warming climates  
- Standardized Values: SPEI values are normally distributed (mean = 0, SD = 1)  
- Research Foundation: Used in thousands of peer-reviewed studies worldwide  

<br>

## The 5-Step SPEI Analysis Framework

### Step 1: Environment Setup and Data Preparation


``` r
# Install required packages if needed
# install.packages(c("SPEI", "tidyverse", "terra", "geodata"))

# Load libraries
library(SPEI)         # Drought index calculations
library(tidyverse)    # Data manipulation and visualization
library(terra)        # Spatial data handling
library(geodata)      # Climate data access

# Create organized directory structure
data_dir <- "data"
dir.create(data_dir, showWarnings = FALSE)
dir.create(file.path(data_dir, "climate"), showWarnings = FALSE)
dir.create(file.path(data_dir, "exports"), showWarnings = FALSE)

# Define forest-themed visualization palette
forest_palette <- colorRampPalette(c("#FFF7BC", "#D9F0A3", "#78C679", "#31A354", "#006837"))

# Load climate data
forest_site_climate <- read_csv("data/climate.csv")

# Preview the data structure
head(forest_site_climate)
#> # A tibble: 6 × 8
#>    year month   lat   lon  tmean  tmin  tmax  prec
#>   <dbl> <dbl> <dbl> <dbl>  <dbl> <dbl> <dbl> <dbl>
#> 1  1960     1  45.1  15.0 -0.609 -4.41  2.71 106. 
#> 2  1960     2  45.1  15.0  1.50  -1.72  4.83 155. 
#> 3  1960     3  45.1  15.0  3.90   1.50  6.94 175. 
#> 4  1960     4  45.1  15.0  7.29   3.92 11.2  131. 
#> 5  1960     5  45.1  15.0 12.2    7.72 16.8   36.2
#> 6  1960     6  45.1  15.0 16.3   11.2  21.6  129.
```

<br>

### Step 2: Calculate Potential Evapotranspiration

The SPEI package provides multiple methods for calculating potential evapotranspiration (PET) based on available data. Important note: All PET calculation methods require the latitude of your study site, as solar radiation varies significantly with geographic location.


``` r
# Extract site latitude (required for all PET calculations)
site_latitude <- unique(forest_site_climate$lat)[1]  # 45.1°N for our forest site

# Method 1: Thornthwaite 
forest_site_climate$PET_thorn <- thornthwaite(Tave = forest_site_climate$tmean, 
                                             lat = site_latitude)
#> [1] "Checking for missing values (`NA`): all the data must be complete. Input type is vector. Assuming the data are monthly time series starting in January, all regular (non-leap) years."

# Method 2: Hargreaves 
forest_site_climate$PET_harg <- hargreaves(Tmin = forest_site_climate$tmin,
                                          Tmax = forest_site_climate$tmax,
                                          lat = site_latitude)
#> [1] "Calculating reference evapotranspiration using the Hargreaves method. Using latitude (`lat`) to estimate extraterrestrial radiation. Checking for missing values (`NA`): all the data must be complete. Input type is vector. Assuming the data are monthly time series starting in January, all regular (non-leap) years."

# Method 3: Penman-Monteith (most accurate - requires additional weather data)
# This method needs wind speed, humidity, solar radiation data
# We'll use Hargreaves for this example as it balances accuracy with data requirements

# Calculate water balance (Precipitation - Potential Evapotranspiration)
forest_site_climate$water_balance <- forest_site_climate$prec - forest_site_climate$PET_harg
```


These methods offer different levels of complexity and accuracy:

- Thornthwaite: Simplest method, only needs temperature data. Good for basic analyses when data is limited.

- Hargreaves: Recommended balance of accuracy and simplicity. Uses temperature range to better estimate PET.

- Penman-Monteith: Most physically-based and accurate, but requires comprehensive weather station data (wind, humidity, solar radiation).

Why latitude matters: Potential evapotranspiration depends heavily on incoming solar radiation, which varies dramatically with latitude and season. The SPEI package uses your site's latitude to calculate accurate solar radiation estimates for each month, ensuring your drought analysis reflects the actual evaporative demand at your forest location.

For forest research, I typically recommend the Hargreaves method as it provides good accuracy while requiring only temperature data that's readily available from most weather stations or climate datasets.

<br>

### Step 3: Calculate SPEI at Multiple Time Scales

This is where SPEI really shines - analyzing drought across different ecological response windows:


``` r
# Calculate SPEI at different temporal scales
spei_3 <- spei(forest_site_climate$water_balance, scale = 3)   # 3-month
#> [1] "Calculating the Standardized Precipitation Evapotranspiration Index (SPEI) at a time scale of 3. Using kernel type 'rectangular', with 0 shift. Fitting the data to a log-Logistic distribution. Using the ub-pwm parameter fitting method. Checking for missing values (`NA`): all the data must be complete. Using the whole time series as reference period. Input type is vector. No time information provided, assuming a monthly time series."
spei_6 <- spei(forest_site_climate$water_balance, scale = 6)   # 6-month  
#> [1] "Calculating the Standardized Precipitation Evapotranspiration Index (SPEI) at a time scale of 6. Using kernel type 'rectangular', with 0 shift. Fitting the data to a log-Logistic distribution. Using the ub-pwm parameter fitting method. Checking for missing values (`NA`): all the data must be complete. Using the whole time series as reference period. Input type is vector. No time information provided, assuming a monthly time series."
spei_12 <- spei(forest_site_climate$water_balance, scale = 12) # 12-month
#> [1] "Calculating the Standardized Precipitation Evapotranspiration Index (SPEI) at a time scale of 12. Using kernel type 'rectangular', with 0 shift. Fitting the data to a log-Logistic distribution. Using the ub-pwm parameter fitting method. Checking for missing values (`NA`): all the data must be complete. Using the whole time series as reference period. Input type is vector. No time information provided, assuming a monthly time series."
spei_24 <- spei(forest_site_climate$water_balance, scale = 24) # 24-month
#> [1] "Calculating the Standardized Precipitation Evapotranspiration Index (SPEI) at a time scale of 24. Using kernel type 'rectangular', with 0 shift. Fitting the data to a log-Logistic distribution. Using the ub-pwm parameter fitting method. Checking for missing values (`NA`): all the data must be complete. Using the whole time series as reference period. Input type is vector. No time information provided, assuming a monthly time series."

# Check calculations
spei_3
#>   [1]           NA           NA  1.002390449  1.330655201  0.201750535
#>   [6] -0.538446815  0.204759508  0.707182175  1.585867338  1.583575448
#>  [11]  1.633573059  1.377190323  0.612706522  0.057879230 -1.317427669
#>  [16] -1.260041677 -0.452900328  0.200863841  1.056663053  0.349989296
#>  [21] -0.799657081 -1.160652364 -0.629127094  0.169876532  0.179879867
#>  [26] -0.086526555  0.843817723  0.970830337  1.498868778  0.612821391
#>  [31]  0.685728429 -0.886183213 -0.963801249 -1.864807733  0.325624999
#>  [36]  0.485914502  1.478069725  0.302578085  0.521887950 -0.231612150
#>  [41]  0.183147444 -0.413005953 -0.154732778  0.129057508  0.743038979
#>  [46]  0.434359251 -0.326775098 -0.626840094 -1.075761714 -1.446558064
#>  [51] -0.896382170 -0.237256294  0.288690255 -0.608251407 -0.099833828
#>  [56]  0.409431784  0.484781437  1.462012346  0.947292205  1.377462573
#>  [61]  0.423951209  0.410566002  0.122263929  0.154126393  1.348723990
#>  [66]  0.904030540  0.516038532  0.587241275  0.978731167 -0.447067453
#>  [71]  0.503696621  0.682630369  1.572583367  0.050170912 -0.284335415
#>  [76] -0.492871410 -0.347938206 -0.513436395  0.941046387  1.549111422
#>  [81]  1.066261874  0.823713141  0.871610858  1.477579450  1.075128163
#>  [86] -0.032757428 -0.413045022  0.033322025  0.101783435  0.354529074
#>  [91] -0.555126760 -0.717599588 -0.669635298 -1.028547124 -0.640694991
#>  [96] -0.670896287 -0.203327563 -0.239022008 -0.959756162 -1.897384289
#> [101] -1.398111157 -0.130206921  0.867726713  1.454500598  1.364829306
#> [106]  0.331519829 -0.508481717 -1.152904729  0.085365970  0.908905776
#> [111]  0.963702867  0.862980420 -0.659824072  0.157531824  0.282907407
#> [116]  1.816787102  0.843019767 -0.320255006 -0.882400793 -0.507985995
#> [121]  0.713877856  0.606598286  1.225239845  1.912175878  1.590659051
#> [126]  0.280704350 -0.405714982  0.158914472 -0.791452041 -1.303865327
#> [131] -1.826807288 -0.935528860 -0.485148786 -0.217975518 -0.238336751
#> [136] -0.597290356 -0.089907225 -0.349098917 -0.228371557 -0.446754895
#> [141] -0.876345786 -1.595038604 -0.971413752 -1.200332449 -0.359551990
#> [146] -0.303433992  0.101589718  1.478166139  2.376912521  2.277883529
#> [151]  1.655341015  0.559774783  1.295780168  0.393695989  0.068094412
#> [156] -0.877350615 -0.789075951 -1.270224704 -0.963086860 -0.733085739
#> [161] -1.550752215 -0.669981576 -0.927791455 -0.524080728 -0.563740541
#> [166] -0.761317326 -0.796162133 -0.958453269 -1.220147102 -1.006875400
#> [171] -0.817830309 -0.145286539  0.436610870  1.292767326  1.198406815
#> [176]  1.676227863  1.368134072  2.229809066  1.555564834  0.728730805
#> [181] -1.654311134 -1.911752303 -0.642040385 -0.202005467  1.048739072
#> [186]  0.923446484  1.281862438  1.221658350  0.076168520  0.182937312
#> [191] -0.618893433 -0.584456512 -1.313389618 -1.430404042 -0.552741042
#> [196] -0.286070426 -0.440529985 -0.735032767 -0.058562160  0.880270951
#> [201]  0.853891884  0.330869454  0.295631607  1.002989115  1.678612678
#> [206]  1.805248575  0.734491351  0.092217417 -0.503396229 -0.927135445
#> [211] -0.372001140  0.109544312  0.404603283 -0.439441490 -0.319219685
#> [216] -0.562016400  0.277774375  0.183623166  1.058070366  1.146560358
#> [221]  1.537562100  1.083214868  0.575308125  0.127257272 -0.108579413
#> [226] -0.797170958 -1.566649587 -1.521763933 -0.416878041  1.040222142
#> [231]  1.201490538  0.661935940 -1.156913559 -1.507392745 -1.157214624
#> [236]  0.363544217  0.549537251  0.196747659  0.191016364  0.552428415
#> [241]  0.919883809  0.129486944 -0.178797766  0.006447467  1.169827331
#> [246]  1.500723984  0.889541719  0.742223748 -0.684757051  0.243614598
#> [251]  1.143619900  1.813973879  1.123731341 -0.248030458 -0.379511188
#> [256] -0.825393035 -0.373340400  1.251282384  1.657792998  0.997698717
#> [261]  0.674802291  0.681418492 -0.174333025  0.266501080 -0.189919253
#> [266]  0.175699143 -1.065667656 -0.772684007  0.015333974 -0.003549174
#> [271] -0.472975136  0.156530584 -0.797834391  0.505452852 -0.127388029
#> [276]  1.246037878  0.160415881  0.987048940  0.287405231  0.057686329
#> [281] -0.695523871 -1.290777314 -1.422781806 -1.338465531 -1.352694035
#> [286] -0.891024038 -1.600155802 -1.700790325 -0.807681772  1.185499779
#> [291]  1.430762565  1.157680022  1.025784544  0.967863665  0.679139748
#> [296]  0.488598311  1.571232380  1.613091098  0.993259766 -0.754274598
#> [301] -0.972828849 -0.890989075  0.749233403  0.960975045  1.097261356
#> [306]  0.054437981 -0.924431822 -1.002680932 -1.824246134 -1.847298857
#> [311] -0.976754362 -0.589111658  0.326578085  0.529010028  0.704037823
#> [316]  0.911830546 -0.405369872  0.674368544  0.626059965  0.936289993
#> [321] -0.554991162 -0.600416682 -1.120656797 -1.111366023 -0.799454890
#> [326]  0.176132723  0.505517118 -0.487923460  0.222365858  0.308278917
#> [331]  0.524176708 -0.767000503 -0.856725447 -0.576344878  0.201968531
#> [336] -0.064342521 -0.026802816  0.117799374  0.959041248  0.894110555
#> [341] -0.298641546 -0.236208879 -0.704078403 -0.342856118 -0.742438656
#> [346] -0.550060376 -1.365441324 -1.694980118 -1.941079785 -1.762165599
#> [351] -1.487446493 -0.299415498  0.918710057  1.825386205  1.898925363
#> [356]  1.644428951  0.805275926 -0.518370701 -1.456001655 -1.944241334
#> [361] -1.847753493 -2.015603451 -1.538199367 -0.727019573 -0.636247547
#> [366] -0.570105575 -0.823879888 -0.854597184 -0.374096427  0.108971245
#> [371]  0.774150349  1.044537250  0.386245460 -0.122588421 -0.852160121
#> [376] -1.023975604  0.750267852  1.130754110  1.529117883 -0.630415213
#> [381] -1.056554066 -0.862192682  0.337914919  0.259395099 -0.518768118
#> [386] -1.801417311 -0.582034792 -0.607238185 -1.055023544 -1.264069741
#> [391] -0.773385359 -0.890746954 -1.659016874  0.954231125  1.455047735
#> [396]  2.095218681 -0.485564647 -1.421381193 -1.618672142 -1.262451125
#> [401] -1.221988829 -0.868674911 -1.329441404 -0.363589373  0.246629676
#> [406]  1.499154665  1.660976793  1.580987604  0.561996326 -0.103703249
#> [411] -0.947408316 -0.482967121 -0.386090486  1.139308938  0.200644394
#> [416]  0.490582126 -0.271004877 -0.026066902 -0.643392719 -0.440702869
#> [421] -0.314790593  0.744557811  1.001183880  0.244247046  0.517137618
#> [426]  1.097020564  1.503105983  1.449657913  0.856477743 -0.045346027
#> [431] -1.083385103 -0.964966700 -0.238536764  0.346684478 -0.873102422
#> [436] -0.736710030 -0.216906494  0.645168700  0.472574001  0.114604574
#> [441]  0.920779975  0.976565733  1.212430647  0.707776134  0.801740126
#> [446] -0.009942111 -0.506811683 -0.558496486 -0.613767206 -0.424535687
#> [451] -0.656436188 -0.229301259 -0.890915886 -1.521484189 -0.893028779
#> [456]  0.171553891  0.764073436 -0.696097733 -1.544634269 -1.535025289
#> [461] -0.569016208 -0.038908911  0.063124693 -0.129462861  1.396909162
#> [466]  1.361476394  1.501934950  0.300488485 -0.337939562  0.053179668
#> [471]  0.279937818  0.765153996  0.722750400  0.953318253  1.651532763
#> [476]  0.713693099  0.225184240 -0.860273618 -0.294531608  0.841648713
#> [481]  0.427786776 -0.352346086 -1.373783547 -1.612116143 -1.701911820
#> [486] -2.173195302 -0.939374918 -1.314646398 -0.587781771 -0.594502972
#> [491]  0.604331757  1.095278658  1.247336579  1.019556198  1.325425081
#> [496]  1.193960918  0.907925634 -0.512996838 -1.274769136 -1.743718986
#> [501] -0.006207808 -0.412399055  0.431569663 -0.957445076 -0.744073479
#> [506] -0.786385868 -1.181575265  0.679832562  0.270366494  0.728871073
#> [511] -0.585857102  0.111551405  1.144575945  0.962808138  0.493601439
#> [516]  0.414483760  0.711997062  0.731076758 -0.413437615 -1.418107506
#> [521] -2.128661609 -1.962460725 -2.364093208 -2.065560649 -1.534497473
#> [526] -0.024024905 -0.027571891 -0.323514792 -0.791741090  0.410821631
#> [531]  0.867290040  1.590999394  1.218299306  1.455468222  0.048173423
#> [536] -0.127228676 -0.503164440  0.458374527  0.184606029  0.378965118
#> [541] -0.527189870 -0.299344846 -0.396625990 -0.014554535  0.204091923
#> [546] -0.069495458 -0.104351091  1.119517829  1.447504043  1.036865507
#> [551]  0.329329279  0.583494729  0.721674193  0.567453279  0.263123589
#> [556]  0.831101472  0.946336285 -0.071343314 -1.502521625  0.316615991
#> [561]  0.316166983  0.079420046 -1.621621315 -1.777311231 -0.802269365
#> [566] -0.138791510  0.624027997 -1.217791477 -1.129538887 -1.486977544
#> [571] -0.353583070 -0.463491622  0.414457973  0.854849101  0.147900755
#> [576] -0.448048839 -0.931271411 -1.005536235  0.058229526  0.388162644
#> [581]  0.849382043  0.081219678 -0.077587098 -0.348182966 -1.152780657
#> [586] -1.258861361 -0.650344475  0.792342147  1.407966761  1.644509407
#> [591]  0.953658444  1.133991371 -0.176071935 -0.763604297 -1.366696770
#> [596] -0.771393097 -1.630603694 -1.344742746 -1.102381602  0.633102442
#> [601]  1.356458948  2.018357463  0.937196195 -0.156793590  0.524630255
#> [606]  0.744547392  0.938981593 -0.279729402  0.684781718  0.461005913
#> [611]  0.981458199  0.606861033  0.603000598 -0.636018805 -1.015657910
#> [616] -1.558962273 -1.254291482 -1.019511448  0.225098373 -0.581743022
#> [621] -1.213143312 -1.263523060 -1.520279799 -0.830301365 -1.369102772
#> [626] -0.503690134 -1.753959708 -1.764523808 -1.252649445 -0.454639415
#> [631] -0.555424639 -1.448790071  0.298926581  1.015761292  1.771613473
#> [636]  1.399066680  1.910061819  2.220121265  2.427467381  1.649667416
#> [641]  1.480445503 -0.720825779 -0.548159647 -1.605129135 -0.439086934
#> [646] -0.375851151  0.826369105 -0.054722800  0.944583646  1.142020599
#> [651]  1.411348415  1.696858019  0.742754364  1.255936752  1.547561620
#> [656]  2.105471845  2.215899731  1.734627935  1.156318051  0.197459078
#> [661] -0.035500405  0.207904194  0.171974264 -0.749914592 -0.908094157
#> [666] -0.799914840 -0.303194194 -0.970214550 -0.925422130  0.969028613
#> [671]  0.214879563 -0.516847141 -1.812538898  0.298976745  1.500827421
#> [676]  1.199895549  0.208294072  0.220188139  0.453350498  0.367452373
#> [681] -0.260706395  0.388298223  0.291525917 -0.435285168 -1.177591449
#> [686] -1.305874623 -0.681284850 -0.737170309 -1.700670905 -1.496376063
#> [691] -1.941704658 -2.131329150  0.892704774  0.795478413  1.695972239
#> [696]  0.969059488  1.736670190  1.941655254  1.325367788  0.765557022
#> [701] -1.013714224 -1.522213122 -1.053376005 -0.810303021 -1.373149035
#> [706] -1.139915490 -0.932108436 -0.919019006

# Extract fitted values and add to dataframe
forest_site_climate$SPEI_3 <- as.numeric(spei_3$fitted)
forest_site_climate$SPEI_6 <- as.numeric(spei_6$fitted)
forest_site_climate$SPEI_12 <- as.numeric(spei_12$fitted)
forest_site_climate$SPEI_24 <- as.numeric(spei_24$fitted)
```

How SPEI Time Scales Work:

SPEI time scales represent rolling accumulation periods. For example:

➡️ **3-month SPEI for June** = water balance accumulated over April + May + June

➡️ **12-month SPEI for June** = water balance accumulated over July (previous year) through June (current year)

➡️ **24-month SPEI for June** = water balance accumulated over June (two years ago) through June (current year)

This rolling calculation captures how forests actually experience drought - they respond not just to current conditions, but to the cumulative water stress over preceding months or years.

📝 **Important Notes:**

Initial NA Values: Notice that longer time scales have more NA values at the beginning of your time series. This is normal - you need at least 24 months of data before you can calculate a 24-month SPEI value.

Matching Scales to Research Questions: Choose your time scale based on what forest process you're studying:

✅ **3-month SPEI:** Perfect for understanding short-term forest productivity changes.

✅ **6-month SPEI:** Critical for understanding yearly growth variations.

✅ **12-month SPEI:** Shows longer-term water stress

✅ **24-month SPEI:** Essential for understanding climate change impacts.


Cumulative Nature: Longer time scales "smooth out" short-term variability and reveal persistent drought patterns. A single dry month might show up strongly in 3-month SPEI but barely register in 24-month SPEI if surrounded by normal conditions.

<br>

### Step 4: Create Publication-Ready Visualizations
Transform your analysis into compelling visuals that communicate drought patterns effectively:


``` r
# Prepare data 
spei_long <- forest_site_climate %>%
    mutate(date = as.Date(paste(year, month, 1, sep = "-"))) %>% 
    select(date, SPEI_3, SPEI_6, SPEI_12, SPEI_24) %>%
    pivot_longer(cols = starts_with("SPEI"), 
                 names_to = "timescale", 
                 values_to = "spei_value") %>%
    filter(!is.na(spei_value)) %>%
    mutate(timescale = factor(timescale, 
                              levels = c("SPEI_3", "SPEI_6", "SPEI_12", "SPEI_24"),
                              labels = c("3-month", "6-month", "12-month", "24-month")))

    ggplot(spei_long, aes(x = date, y = spei_value)) +
    # Add horizontal reference line
    geom_hline(yintercept = 0, color = "black", linetype = "solid", size = 0.5) +       # Normal     conditions
 
    # Create colored bars 
    geom_col(aes(fill = ifelse(spei_value >= 0, "Wet", "Drought")), 
             width = 25, alpha = 0.7) + 
    
    # Custom colors for the bars
    scale_fill_manual(values = c("Drought" = "red", "Wet" = "blue"),
                      name = "Condition") +
    
    # Facet by time scale
    facet_wrap(~timescale, ncol = 1, scales = "fixed") +
    
    # Customize x-axis to show your study period
    scale_x_date(date_breaks = "10 years", date_labels = "%Y",
                 limits = as.Date(c("1960-01-01", "2018-12-31"))) +
    
    # Set y-axis limits to match your reference image
    scale_y_continuous(limits = c(-3, 3), breaks = seq(-2, 2, 1)) +
    
    # Labels and styling
    labs(
        title = "Multi-Scale Drought Analysis for Forest Site (1960-2018)",
        subtitle = "SPEI reveals drought patterns across different ecological time scales",
        x = "Year",
        y = "SPEI Value",
        caption = "Red bars: drought conditions | Blue bars: wet conditions\nModerate drought: SPEI < -1.0 | Severe drought: SPEI < -1.5 | Extreme drought: SPEI < -2.0"
    ) +
    
    # Clean, publication-ready theme
    theme_minimal() +
    theme(
        plot.title = element_text(size = 16, face = "bold", margin = margin(b = 10)),
        plot.subtitle = element_text(size = 12, color = "gray30", margin = margin(b = 15)),
        strip.text = element_text(size = 12, face = "bold", margin = margin(b = 5)),
        panel.grid.minor = element_blank(),
        panel.grid.major.x = element_line(color = "gray90", size = 0.3),
        panel.grid.major.y = element_line(color = "gray90", size = 0.3),
        axis.text.x = element_text(angle = 0, hjust = 0.5),
        plot.caption = element_text(size = 9, color = "gray50", hjust = 0),
        panel.spacing = unit(0.8, "lines"),
        legend.position = "none"  
    )
```

<div class="figure" style="text-align: center">
<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-4-1.png" alt="Multi-scale SPEI analysis showing drought patterns across different ecological time scales." width="80%" />
<p class="caption"><span id="fig:unnamed-chunk-4"></span>Figure 1: Multi-scale SPEI analysis showing drought patterns across different ecological time scales.</p>
</div>

<br>

### Step 5: Drought Event Analysis and Characterization
Identify and analyze significant drought events for forest impact assessment:


``` r
# Define drought severity categories
drought_categories <- function(spei) {
  case_when(
    spei >= 2.0   ~ "Extremely wet",
    spei >= 1.5   ~ "Very wet", 
    spei >= 1.0   ~ "Moderately wet",
    spei >= -1.0  ~ "Normal",
    spei >= -1.5  ~ "Moderately dry",
    spei >= -2.0  ~ "Severely dry", 
    TRUE          ~ "Extremely dry"
  )
}

# Identify extreme drought events (SPEI < -1.5)
extreme_droughts <- forest_site_climate %>%
  filter(SPEI_12 < -1.5) %>%
  mutate(drought_category = drought_categories(SPEI_12)) %>%
  select(year, month, SPEI_12, drought_category)

# Summarize drought characteristics
drought_summary <- extreme_droughts %>%
  arrange(year, month) %>%
  mutate(
    year_month = year + (month - 1) / 12,
    month_diff = c(1, diff(year_month)),
    drought_event = cumsum(month_diff > 0.15)  # Group consecutive months
  ) %>%
  group_by(drought_event) %>%
  summarise(
    start_year = min(year),
    start_month = month[which.min(year_month)],
    end_year = max(year),
    end_month = month[which.max(year_month)],
    duration_months = n(),
    min_spei = min(SPEI_12),
    mean_spei = mean(SPEI_12)
  ) %>%
  arrange(min_spei)

print(drought_summary)
#> # A tibble: 13 × 8
#>    drought_event start_year start_month end_year end_month duration_months
#>            <int>      <dbl>       <dbl>    <dbl>     <dbl>           <int>
#>  1             7       1990           5     1990        10               6
#>  2            12       2011          11     2012         8              10
#>  3             3       1973           9     1974         4               8
#>  4             4       1983          11     1984         1               3
#>  5             6       1989           1     1989         5               5
#>  6             9       2003          11     2004         2               4
#>  7            13       2017           7     2017         8               2
#>  8             5       1985          10     1985        10               1
#>  9             1       1968           4     1968         4               1
#> 10             2       1971          10     1971        10               1
#> 11             8       2003           9     2003         9               1
#> 12            11       2007           8     2007         8               1
#> 13            10       2007           4     2007         4               1
#> # ℹ 2 more variables: min_spei <dbl>, mean_spei <dbl>

# Show key drought events with SPEI values
drought_summary %>%
  select(start_year, duration_months, min_spei, mean_spei) %>%
  slice_min(min_spei, n = 5) %>%
  mutate(
    min_spei = round(min_spei, 2),
    mean_spei = round(mean_spei, 2)
  ) %>%
  print()
#> # A tibble: 5 × 4
#>   start_year duration_months min_spei mean_spei
#>        <dbl>           <int>    <dbl>     <dbl>
#> 1       1990               6    -2.25     -1.89
#> 2       2011              10    -2.2      -2.01
#> 3       1973               8    -2.12     -1.7 
#> 4       1983               3    -2.01     -1.71
#> 5       1989               5    -2.01     -1.79
```

13 distinct drought events were identified over the study period, with the most severe reaching SPEI values of -2.25 in 1990. The longest drought lasted 10 months (2011-2012), creating sustained stress that would significantly impact forest health and growth.

<br>

## Real Results from Forest Research
This SPEI analysis workflow delivers measurable benefits for forest researchers:

✅ Enhanced Predictive Capability: Detect drought stress months before visible symptoms

✅ Standardized Assessment: Compare drought impacts across regions and forest types

✅ Multi-scale Understanding: Match analysis to specific ecological processes

✅ Climate-Smart Management: Incorporate temperature effects in drought planning

✅ Reproducible Methods: Code-based workflows ensure transparent, repeatable analysis


<br>

## References

1. Hargreaves, G.H., & Samani, Z.A. (1985). Reference crop evapotranspiration from temperature. *Applied Engineering in Agriculture*, 1(2), 96-99. [https://doi.org/10.13031/2013.26773](https://doi.org/10.13031/2013.26773)

2. Palmer, W.C. (1965). Meteorological drought. *Research Paper No. 45*, U.S. Department of Commerce, Weather Bureau, Washington, D.C.

3. Thornthwaite, C.W. (1948). An approach toward a rational classification of climate. *Geographical Review*, 38(1), 55-94. [https://doi.org/10.2307/210739](https://doi.org/10.2307/210739)

4. Vicente-Serrano, S.M. (2024). SPEI: Calculation of the Standardised Precipitation-Evapotranspiration Index. R package version 1.8.1. [https://CRAN.R-project.org/package=SPEI](https://CRAN.R-project.org/package=SPEI)

<br>
<br>

---

<br>

**Need Advanced Forest Data Science?**

*I help research organizations transform their data workflows from manual to automated, providing comprehensive services from statistical analysis and modeling to spatial data integration and advanced visualizations. If you're spending days on data collection and processing instead of focusing on analysis and insights, let's talk about how custom R solutions can streamline your research pipeline.*

*My clients typically see:*

* *90% reduction in data processing time*
* *Improved accuracy through automated workflows*
* *Rigorous statistical insights that strengthen research conclusions*
* *Reproducible analyses that scale across projects*

📩*Contact me: marijana@andalytics.com*

