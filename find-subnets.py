#!/usr/bin/env python3

import sys
import json

def get_rule_names(x): return x['rule_name']


def get_subnet_ids(x): return x['subnet_id']


def find_subnet_rules(env, product, subnets):
    all_subnets = get_all_subnets(env, product, subnets)

    rule_names = list(map(get_rule_names, all_subnets))
    subnet_ids = list(map(get_subnet_ids, all_subnets))

    result = {}
    result['subnets'] = ';'.join(subnet_ids)
    result['rule_names'] = ';'.join(rule_names)
    return result


def get_all_subnets(env, product, subnets):
    environments = subnets['environments']
    env_subnets_list_of_lists = [environment['subnets']
                                 for environment in environments if environment['name'] == env]

    applications = subnets['applications']
    app_subnets_list_of_lists = [application['subnets']
                                 for application in applications if application['name'] == product]

    if len(env_subnets_list_of_lists) == 0 and len(app_subnets_list_of_lists) == 0:
        # terraform will say "command "python3" failed with no error message"
        # still better to fail here I think
        print('No subnets found')
        sys.exit(1)

    # get first element or empty list if none
    env_subnets = next(iter(env_subnets_list_of_lists), [])
    app_subs = next(iter(app_subnets_list_of_lists), [])

    all_subnets = env_subnets + app_subs
    return all_subnets


# always only one line from terraform
# {"env":"idam-aat","product":"idam-idm-aat"}
line = sys.stdin.readline()
query = json.loads(line)

with open(sys.path[0] + '/subnets.json', 'r') as subnets_string:
    subnets = json.load(subnets_string)
    env = query['env']
    product = query['product']

    result = find_subnet_rules(env, product, subnets)
    print(json.dumps(result))
