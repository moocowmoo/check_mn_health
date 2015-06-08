# check_mn_health.sh

simple bash script to collect masternode status information

run on masternode host

requires dash-cli binary

example invocation:

    $ check_mn_health.sh
    collecting info... DONE

     ----
          dashd: RUNNING LISTENING CURRENT
     masternode: STARTED VISIBLE   HEALTHY
     ----
       instance information
         IP Address         123.123.123.123
         dashd version      v11.02.23
         dashd connections  15
         service score      0
         dashd last block   282232
         chainz last block  282232
         masternode total   2655
         masternode healthy 2465
     ----
       current vote counts
                       YEA: 0
                       NAY: 0
                   ABSTAIN: 2656
                 this vote: ABSTAIN
  
