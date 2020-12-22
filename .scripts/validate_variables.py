#! /usr/bin/env python3

import hcl2
import glob
import sys


def get_variables():
    variables = {}
    for file in glob.glob("**/variables.tf", recursive=True):
        with open(file, "r") as f:
            data = hcl2.load(f)
            for var in data['variable']:
                name = list(var.keys())[0]
                if name not in variables.keys(): variables[name] = {"definitions":[]}
                if "description" in list(var[name].keys()):
                    v_description = var[name]["description"][0]
                else:
                    v_description = "NULL"
                if "type" in list(var[name].keys()):
                    v_type = var[name]["type"][0]
                else:
                    v_type = "NULL"
                variables[name]["definitions"].append({"type": v_type, "description": v_description, "used_in": "/".join(file.split("/")[1:-1])})
    return variables


def validate():
    result = 0
    variables = get_variables()
    for var_name in variables.keys():
        var = variables[var_name]
        problems = []
        if len(set([i["description"] for i in var["definitions"]])) > 1: problems.append("description")
        if len(set([i["type"] for i in var["definitions"]])) > 1: problems.append("type")
        if len(problems) > 0:
            result = 1
            sys.stderr.write("[\033[0;31mERROR\033[0m] Variable \033[0;32m%s\033[0m is used in %s, need to fix %s\n" % (var_name, ", ".join([i["used_in"] for i in var["definitions"]]), " and ".join(problems)))
    sys.exit(result)


def check(name):
    v = get_variables()[name]
    sys.stdout.write("Variable \033[0;32m%s\033[0m:\n" % name)
    for d in v["definitions"]:
        sys.stdout.write("\tmodule: %s\n\ttype: %s\n\tdescription: %s\n\n" % (d['used_in'],d['type'],d['description']))
    sys.stdout.write("Status: \033[0;32m%s\033[0m" % str(len(set([i["description"] for i in v["definitions"]])) == 1))


if __name__ == "__main__":
    if len(sys.argv) > 2:
        if sys.argv[1] == "check": check(sys.argv[2])
    else:
        validate()
