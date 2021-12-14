#!/bin/zsh

#check CDK available
cdk=$(which cdk)
if [[ ! $cdk =~ "cdk" ]] ; then
    print -P "\n%F{red}%SNo CDK installed%s%f\n\n%F{yellow}Please install CDK and try again.%f\n\n"
    exit
fi

#get the profile if there is one
for i in {1..$#}
do
    if [[ $@[i] = "--profile" ]] ; then
        profile=$@[i+1]
    fi
done

#if --profile supplied, check if it has a valid token, otherwise check default credentials
if [[ $profile != "" ]] ; then
    echo "Checking valid credentials for $profile"
    token_ok=$(aws sts get-caller-identity --profile $profile 2>&1)
else
    token_ok=$(aws sts get-caller-identity 2>&1)
fi

#setup the test strings
bad_token="is expired"
has_error="exited with error"
is_unchanged="no differences"
has_replacement="requires replacement"
has_destroy="destroy"
has_open_rules="0.0.0.0"

# test the token
if [[ $token_ok =~ $bad_token ]] ; then
    print -P "\n%F{red}%SNo valid token%s%f\n\n%F{yellow}Please make sure you are logged in and try again.%f\n\n"
    exit
else
    print -P "\n✅  %F{green}Got a valid token%f\n"
fi

# do the diff
echo '\n\nDiffing stack...\n\n'
result=$(cdk diff $* 2>&1)

#print the output
echo ${result//$'\n'/'\n\r'} 

#if the diff failed, just bail
if [[ $result =~ $has_error ]] ; then
    echo '\n\n'
    print -P "%F{red}%SD'OH!%s : %BThere are errors in your project.%b%f\n\n%F{yellow}Please check the above output, fix your project and try again.%f\n\n"
    exit
else
    #were there any differences?
    if [[ $result =~ $is_unchanged ]] ; then
        print -P "✅ %F{green} Nothing to do!%f"
    else
        echo '\n\nSynthing stack...\n\n'
        warnings=""
        ok=""
        # do the synth
        cf_template=$(cdk synth $* 2>&1)
        if [[ $cf_template =~ $has_open_rules ]] ; then
            warnings+="❌ %F{red}%S SECURITY WARNING%s : %BCOULD CONTAIN RESOURCES THAT ARE OPEN TO THE INTERNET!%b%f\n\n"
        else
            ok+="✅ %F{green} No open rules (0.0.0.0/0) are in this stack.%f\n"
        fi
        #were there any changes we should check carefully? 
        #replacements?
        if [[ $result =~ $has_replacement ]] ; then
            warnings+="❌ %F{red}%S REPLACEMENT WARNING%s : %BTHERE ARE RESOURCES THAT ARE GOING TO BE REPLACED!%b%f\n\n"
        else
            ok+="✅ %F{green} No resources are expected to be replaced.%f\n"
        fi
        #destroys?
        if [[ $result =~ $has_destroy ]] ; then
            warnings+="⛔️ %F{red}%SDESTROY WARNING%s : %BTHERE ARE RESOURCES THAT ARE GOING TO BE DESTROYED!%b%f\n\n"
        else
            ok+="✅ %F{green} No resources are expected to be destroyed.%f\n"
        fi
        if [[ $warnings != "" ]] ; then
            print -P $warnings
            print -P "%F{yellow}Please check the above output carefully %SBEFORE%s you proceed.%f\n"
        fi
        print -P $ok
        #there were diffs, so have a look at them before you deploy!
        read "proceed?There were diffs for your review. Are the changes good to deploy? [y/N] "
        if [[ $proceed == "y" ]] ; then
            print -P "\n%F{green} ▶ Deploying%f\n"
            cdk deploy $*
        else 
            print -P "\n%F{blue} ▧ NOT deploying\n"
        fi
    fi
fi