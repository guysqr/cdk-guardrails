# CDK Armour

A wrapper script you can use to protect yourself from CDK deploy mishaps.

![image](https://user-images.githubusercontent.com/52842774/145179579-bf67aec9-78a9-4d8b-b326-105e55a8a6e6.png)

## Purpose
If you deploy using CDK from the CLI, you might sometimes get carried away and accidentally deploy a change that has consequences you didn't anticipate. This script aims to protect you from yourself.

## To use
Simply drop the script into your CDK project and `chmod +x` it. Then, instead of

```
cdk deploy mystack -c arg=v --profile my-profile
```

You type

```
./deploy.sh mystack -c arg=v --profile my-profile
```

It will do a `cdk diff` for you and let you know if there is anything wrong, before offering to run `cdk deploy` for you.

*Note: currently only in zsh-compatible form.*
