# CDK Guardrails

A wrapper script you can use to protect yourself from CDK deploy mishaps.

![cdk-guardrails-nobars](https://user-images.githubusercontent.com/52842774/145279095-4d498c92-7b2b-4249-bcfd-660741b891b9.png)

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
