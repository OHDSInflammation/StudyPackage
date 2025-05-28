## generate cohorts using Capr
#remotes::install_github("ohdsi/Capr")
library(Capr)

asthma <- cs(c(252658,256448,257581,312950,313236,317009,443801,761844,764677,764949,1340255,3661412,4022592,4051466,4057952,4075237,4080516,4110051,4119298,4119300,4120261,4123253,4138760,4141978,4142738,4143474,4143828,4145356,4145497,4146581,4152913,4155468,4155469,4155470,4191479,4206340,4211530,4212099,4217558,4225553,4225554,4232595,4233784,4244339,4245292,4245676,4250128,4271333,4301938,4309833,4312524,35609846,35609847,36684328,36684335,37108580,37108581,37109103,37116845,37206717,37208352,37310241,40481763,40483397,42535716,42536207,42536208,42536649,42538744,42539549,43530693,43530745,44810117,45757063,45766727,45766728,45768910,45768911,45768912,45768963,45768964,45768965,45769350,45769351,45769352,45769438,45769441,45769442,45769443,45772073,45772937,45773005,46269767,46269770,46269771,46269776,46269777,46269784,46269785,46269801,46269802,46270028,46270029,46270030,46270322,46273452,46273454,46273462,46273635,46274059,46274062,46274124),
          name = "asthma broad (condition)")

inhaled_beta2 <- cs(c(584875), 
                    name = "inhaled beta-2")

oral_steroids <- cs(c(584875), 
                    name = "oral steroids")


## loop through the different severity levels and pre and post covid 

ch_entry = entry(
  conditionOccurrence(asthma),
  startDate("2024-01-01"), endDate("2024-06-30"),
  observationWindow = continuousObservation(180,1), 
  primaryCriteriaLimit = "First",
  qualifiedLimit = "First"
)

ch <- cohort(
  entry = ch_entry,
  ## attrition criteria leidy
  attrition(
    "leidySevere" = withAny(
      # with at most 1 inhaled beta-2 and at least 3 oral steriods
      withAll(
        atMost(
          x = 1,
          aperture = duringInterval(eventStarts(-548, 0)),
          query = drugExposure(conceptSet = inhaled_beta2)
        ),
        atLeast(
          x = 3,
          aperture = duringInterval(eventStarts(-548, 0)),
          query = drugExposure(conceptSet = oral_steroids)
        )
      ),
      # with at most 2 inhaled beta-2 and at least 3 oral steriods
      withAll(
        atMost(
          x = 2,
          aperture = duringInterval(eventStarts(-548, 0)),
          query = drugExposure(conceptSet = inhaled_beta2)
        ),
        atLeast(
          x = 3,
          aperture = duringInterval(eventStarts(-548, 0)),
          query = drugExposure(conceptSet = oral_steroids)
        )
      ),
      # with at most 3 inhaled beta-2 and at least 3 oral steriods
      withAll(
        atMost(
          x = 3,
          aperture = duringInterval(eventStarts(-548, 0)),
          query = drugExposure(conceptSet = inhaled_beta2)
        ),
        atLeast(
          x = 3,
          aperture = duringInterval(eventStarts(-548, 0)),
          query = drugExposure(conceptSet = oral_steroids)
        )
      ),
      # with at most 4 inhaled beta-2 and at least 3 oral steriods
      withAll(
        atMost(
          x = 4,
          aperture = duringInterval(eventStarts(-548, 0)),
          query = drugExposure(conceptSet = inhaled_beta2)
        ),
        atLeast(
          x = 3,
          aperture = duringInterval(eventStarts(-548, 0)),
          query = drugExposure(conceptSet = oral_steroids)
        )
      ),
      # with at most 5 inhaled beta-2 and at least 3 oral steriods
      withAll(
        atMost(
          x = 5,
          aperture = duringInterval(eventStarts(-548, 0)),
          query = drugExposure(conceptSet = inhaled_beta2)
        ),
        atLeast(
          x = 3,
          aperture = duringInterval(eventStarts(-548, 0)),
          query = drugExposure(conceptSet = oral_steroids)
        )
      ),
      # with at most 6 inhaled beta-2 and at least 3 oral steriods
      withAll(
        atMost(
          x = 6,
          aperture = duringInterval(eventStarts(-548, 0)),
          query = drugExposure(conceptSet = inhaled_beta2)
        ),
        atLeast(
          x = 3,
          aperture = duringInterval(eventStarts(-548, 0)),
          query = drugExposure(conceptSet = oral_steroids)
        )
      ),
      # with at most 7 inhaled beta-2 and at least 2 oral steriods
      withAll(
        atMost(
          x = 7,
          aperture = duringInterval(eventStarts(-548, 0)),
          query = drugExposure(conceptSet = inhaled_beta2)
        ),
        atLeast(
          x = 2,
          aperture = duringInterval(eventStarts(-548, 0)),
          query = drugExposure(conceptSet = oral_steroids)
        )
      )
    )
  ),
  exit = exit(
    endStrategy = observationExit()
  )
)

cohortJson <- compile(ch)
writeLines(cohortJson, con = "cohort_definition.json")


