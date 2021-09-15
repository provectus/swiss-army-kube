# Contributing Pull Requests

This guide is written for contributing to documentation. It doesn't contain any instructions on installing software prerequisites. If your intended contribution requires any software installations, please refer to their respective official documentation.

**Prerequisites**
* Git installed on your local machine
* GitHub account

**Contents**

2. [PR Contribution Workflow](#workflow)
3. [Basic Workflow Example](#example)
4. [PR Acceptance policy](#accept)

<a name="workflow"></a>
## PR Contribution Workflow

1. [Fork and clone this repository (`git clone`)](#clonerepo)
2. [Create a feature branch against master (`git checkout -b featurename`)](#checkout)
3. [Make changes in the feature branch](#editdoc)
4. [Update the documentation](#docs)
5. [Use Linter to ensure correct syntax and formatting (`terraform fmt`, `pre-commit run -a`)](#lintit)
6. [Commit your changes (`git commit -am "Add a feature"`)](#commit)
7. [Push your changes to GitHub (`git push origin feature`)](#push)
8. [Open a Pull Request and wait for your PR to get reviewed](#openPR)
9. [Edit your PR to address feedback (if any)](#modifyPR)
10. [See your PR getting merged](#merged)

<a name="clonerepo"></a>
### 1. Fork and Clone this Repository

In order to contribute, you need to make your own copy of the repository you're going to contribute to. You do this by forking the repository to your GitHub account and then cloning the fork to your local machine.

1. Fork this GitHub repository: on GitHub, navigate to the [main page of the repository](https://github.com/provectus/swiss-army-kube) and click the Fork button in the upper-right area of the screen. This will create a fork (a copy of this repository in your GitHub account).
2. Clone the fork and switch to the project directory by running in your terminal:
```
git clone https://github.com/provectus/swiss-army-kube.git
cd swiss-army-kube
```
<a name="checkout"></a>
### 2. Create a New Branch
It is important to make all your changes in a separate branch created off the master branch.
Before any modifications to the repository that you've just cloned, create a new branch off of the master branch.

Create a new branch off of the current one and switch to it:
```
git checkout -b <your-branch-name>
```
To switch between branches, use the same command without the `-b` flag. For example, to switch back to the master branch:
```
git checkout master
```
This way you can switch between multiple branches when you work on multiple features at once.

#### Branch Naming Conventions

Give your branch a descriptive name so that others working on the project understand what you are working on. The branch name should include the name of the module that you're contributing to.

Name your branch according to the following template, replacing `nginx` with the name of the module you're contributing to:
```
feature/docs_nginx
```

<a name="editdoc"></a>
### 3. Make Changes

Make changes you want to propose. Make sure you do this in a dedicated branch based on the master branch.

<a name="docs"></a>
### 4. Update the documentation

Make sure to update the documentation. Each module should be properly documented:
- the purpose of the module is stated;
- pre-requisites and requirements for the module are given;
- there is a list of input and output variables used inside the module.

You can use [`terraform-docs`](https://github.com/terraform-docs/terraform-docs/) to automatically generate the documentation for the module

<a name="lintit"></a>
### 5. Use Linter for Correct Syntax & Formatting

When applicable, use linters for Terraform to ensure proper formatting before committing and pushing your changes. Check your repository with one of them:
* **[Terraform formatting](https://www.terraform.io/docs/commands/fmt.html)** - run `terraform fmt && tflint`
* **[pre-commit-terraform](https://github.com/antonbabenko/pre-commit-terraform)** - run `pre-commit run -a` after installing and configuring the tool.

<a name="commit"></a>
### 6. Commit Changes
Commit changes often to avoid accidental data loss. Make sure to provide your commits with descriptive comments.

```
git add .
git commit -m "Add description"
```
Or add and commit all changed files with one command:
```
git commit -am "Add description"
```

<a name="push"></a>
### 7. Push Changes to GitHub

Push your local changes to your fork on GitHub.
```
git push <repo-name> <branch-name>
```
For example, if your remote repository is called origin and you want to push a branch named Mod-argo:
```
git push origin Mod-argo
```

<a name="openPR"></a>
### 8. Open a Pull Request

Navigate to your fork on GitHub. Press the "New pull request" button in the upper-left part of the page. Add a title and a comment. Once you press the "Create pull request" button, the maintainers of this repository will receive your PR.

<a name="modifyPR"></a>
### 9. Address Feedback

After you submit the PR, one or several of the Swiss Army Kube reviewers will provide you with actionable feedback. Edit your PR to address all of the comments. Reviewers do their best to provide feedback and approval in a timely fashion but note that response time may vary based on circumstances.

<a name="merged"></a>
### 10. Your PR Gets Merged

Once your PR is approved by a reviewer, it gets accepted and merged with the main repository. Merged PRs will get included in the next Swiss Army Kube release.

<a name="example"></a>
## Basic Workflow Example
```
git clone https://github.com/provectus/swiss-army-kube.git
cd swiss-army-kube
git checkout -b Mod-argo
git status
terraform fmt
git commit -am "Add description"
git push origin Mod-argo
```
<a name="accept"></a>
## PR Acceptance Policy

What will make your PR more likely to get accepted:

* Having your fixes on a dedicated branch
* Proper branch naming
* Descriptive commit messages
* PR title describing what changed
* PR comment describing why/where it changed in <80 chars
* Texts checked for spelling and typos (you can use Grammarly)
* Terraform code snippets checked with linters (when applicable)

### PR Title and Comment Conventions

A PR title should describe what has changed. A PR comment should describe why and what/where. If your changes relate to a particular issue, a PR comment should contain an issue number. Please keep PR comments below 80 characters for readability.

PR title rules:
  1. Min/Max length 5-100
  2. Must start with prefix  (Allowed prefixes: feature,fix,issue,bug,docs,cicd)

PR title example:
```
issue: added 2 sections and notification. System: new structure, description, minor fixes.
```

PR comment example:

```
Kubernetes: added sections: "Requirements", "How to update SAK module Kubeflow".
Added version table showing the compatibility of Kubernetes and Kubeflow versions.
Added notification about changes to what files will trigger Kubeflow terraform
resources recreation.

System: rearranged file structure according to best practice. Finished the module
description section. Added a warning about using GPUs and a container. Fixed typos
and formatting throughout the whole file.

Issue #42
```

Minor edits (typos, spelling, formatting, adding small text pieces) may get waved through. More substantial changes normally require more time, reviewers, and back-and-forths, and you might get asked for a PR resubmission or dividing changes into more that one PR. Usually, PRs are getting merged right after the approval.
