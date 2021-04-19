# Contributing Guide

## What You Can Help With

Currently, we accept contributions to the documentation of modules, specifically README.md files of each module. You can contribute in the following ways:
* Create a new Readme that is currently missing, add structure and write it in full or in part
* Add missing sections, paragraphs, and information to existing READMEs
* Correct typos and formatting issues
* Add/propose graphics to illustrate documentation

## Getting Started

Swiss Army Kube documentation welcomes improvements from all contributors, new and experienced. Anyone can contribute to the `github.com/provectus/swiss-army-kube` repository in the following formats:
1. Open an issue about the documentation
2. Propose a change with a pull request (PR)
3. Propose minor text/formatting edits right on GitHub without cloning

All you need is being comfortable with Git and GitHub.

## Contributing Issues

Find an [issue](https://github.com/provectus/swiss-army-kube/issues) to work on or create your own. If you are a new contributor take a look at issues marked with `good first issue`.

## Contributing Pull Requests (PRs)

Please check our guide on how to contribute to Swiss Army Kube with PRs:
* [Contributing Pull Requests](https://github.com/provectus/swiss-army-kube/blob/master/docs/CONTRIBUTE_PR.md)

## Select a Module to Contribute

The list of all Swiss Army Kube modules below includes information on the current state of documentation for each Module.
Please select a module to contribute:
*  [airflow](https://github.com/provectus/sak-incubator/tree/main/airflow)                          (has short annotation)
*  [cicd](https://github.com/provectus/sak-incubator/tree/main/cicd)                                (no Readme)
    + [argo](https://github.com/provectus/sak-incubator/tree/main/cicd/argo)                        (no Readme)
    + [jenkins](https://github.com/provectus/sak-incubator/tree/main/cicd/jenkins)                  (no Readme)
*  [ingress](https://github.com/provectus/sak-incubator/tree/main/ingress)                          (empty Readme)
    + [nginx](https://github.com/provectus/sak-incubator/tree/main/ingress/nginx)                   (has short annotation)
    + [alb-ingress](https://github.com/provectus/sak-incubator/tree/main/ingress/alb-ingress)       (has short annotation)
*   [kubeflow](https://github.com/provectus/sak-incubator/tree/main/kubeflow)                       (has Readme)
*   **[kubernetes](https://github.com/provectus/sak-incubator/tree/main/kubernetes)**               (has short annotation)
*   [logging](https://github.com/provectus/sak-incubator/tree/main/logging)                         (empty Readme)
    + [efk](https://github.com/provectus/sak-incubator/tree/main/logging/efk)                       (empty Readme)
    + [loki](https://github.com/provectus/sak-incubator/tree/main/logging/loki)                     (empty Readme)
*   [monitoring](https://github.com/provectus/sak-incubator/tree/main/monitoring)                   (empty Readme)
    + [prometheus](https://github.com/provectus/sak-incubator/tree/main/monitoring/prometheus)      (no Readme)
*   **[network](https://github.com/provectus/sak-incubator/tree/main/network)**                     (empty Readme)
*   [rds](https://github.com/provectus/sak-incubator/tree/main/rds)                                 (no Readme)
*   [scaling](https://github.com/provectus/sak-incubator/tree/main/scaling)                         (no Readme)
*   [storage](https://github.com/provectus/sak-incubator/tree/main/storage)                         (no Readme)
    + [efs](https://github.com/provectus/sak-incubator/tree/main/storage/efs)                       (empty Readme)
    + [fsx](https://github.com/provectus/sak-incubator/tree/main/storage/fsx)                       (no Readme)
*  **[system](https://github.com/provectus/sak-incubator/tree/main/system)**                        (has short annotation)

## Structure of a Module's README

Approximate structure of a README.md document:

* Module Description
* Implementation
* Usage
* Configuration
* Overrides

In some cases, modules won't need some of these sections or require additional ones. Change it according to a particular module.

<a href="#top">Back to top</a>
