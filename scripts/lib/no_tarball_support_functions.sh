#!/bin/bash

PATH="/opt/puppetlabs/puppet/bin:/opt/puppet/bin:$PATH"
function test_for_initial_puppet_run(){
  PUPPET_RUNNING=$(ps -ef | grep 'waitforcert' | grep -v grep | wc -l)
}

# Make sure that a puppet agent run happens on the master
# after classifying it with the necessary platform support classes.
function wait_for_initial_puppet_run(){
  echo "Waiting for initial puppet run to complete,"
  echo "to ensure that platform supporting classes are in place."

  test_for_initial_puppet_run

  if [ $PUPPET_RUNNING == "0" ]
  then
    echo "Sleeping for 30 seconds to allow initial puppet run to begin."
    sleep 30
    test_for_initial_puppet_run

    if [ $PUPPET_RUNNING == "0" ]
    then
      echo "Puppet run not initiated after 30 seconds."
      echo "Triggering puppet run."
      puppet agent -t
    else
      while [ $PUPPET_RUNNING == "1" ]
      do
        echo "Puppet run is in progress."
        echo "Sleeping for 30 seconds..."
        sleep 30
        test_for_initial_puppet_run
      done
    fi
  fi

  echo "Puppet run is complete."
}
