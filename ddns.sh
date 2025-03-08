#!/bin/bash

# if there is no repo/ssh-key, we just bail
if [[ -n ${DDNS_REPO} ]] && [[ -n ${DDNS_SSH_KEY} ]] ; then

    echo "${DDNS_SSH_KEY}" > ./ssh-key
    chmod 600 ${PWD}/ssh-key

    eval $(ssh-agent -s)
    SSH_ASKPASS_REQUIRE=force SSH_ASKPASS=${PWD}/ssh_give_pass.sh ssh-add ${PWD}/ssh-key <<< ${DDNS_SSH_PASSPHRASE}

    #start fresh
    rm -rf ddns_git
    echo "clone repo: ${DDNS_REPO}"
    git clone ${DDNS_REPO} ddns_git
    cd ddns_git

    #configuring the committer
    echo "configuring git committer"
    git config user.name "${DDNS_GIT_USERNAME}"
    git config user.email "${DDNS_GIT_EMAIL}"

    #start looping, we check against IP, then
    while true
    do
	CURR_IP="$(curl 'https://api.ipify.org?format=json')"

	if [[ -z ${CURR_IP} ]]; then
	    echo "it seems you lost your internet connections. try again later..."
	elif [[ ! -f ip_stat ]] || [[ ! "$(cat ip_stat)" == ${CURR_IP} ]]; then
	    echo "need to update current ip: ${CURR_IP}"
	    echo ${CURR_IP} > ip_stat
	    git add ip_stat
	    git commit -m "updating IP on $(date)"
	    git push origin main
	else
	    echo "nothing to update now: ip ${CURR_IP}"
	fi
	#sleep for very long time
	sleep ${DDNS_TIMEOUT}
    done

else
    echo "no DDNS_REPO or DDNS_SSH_KEY available, quit"
fi
