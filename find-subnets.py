#!/usr/bin/env python3

import sys
import json
import urllib.request


def find_subnet_rules(env, product, subnets):
    all_subnets = get_all_subnets(env, product, subnets)

    rule_names = [x['rule_name'] for x in all_subnets]
    subnet_ids = [x['subnet_id'] for x in all_subnets]

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

    env_subnets = env_subnets_list_of_lists[0] if len(
        env_subnets_list_of_lists) > 0 else []
    app_subs = app_subnets_list_of_lists[0] if len(
        app_subnets_list_of_lists) > 0 else []

    all_subnets = env_subnets + app_subs
    return all_subnets


# always only one line from terraform
# {"env":"idam-aat","product":"idam-idm-aat", "github_token": "example"}
line = sys.stdin.readline()
query = json.loads(line)

subnets_filename = query['subnets_filename']
github_token = query['github_token']

url = 'https://raw.githubusercontent.com/hmcts/cnp-database-subnet-whitelisting/master/%s' % subnets_filename

req = urllib.request.Request(
    url=url, headers={'Authorization': 'Bearer ' + github_token})

with urllib.request.urlopen(req) as f:
    subnets_str = f.read().decode('utf-8')
    subnets = json.loads(subnets_str)

    env = query['env']
    product = query['product']

    result = find_subnet_rules(env, product, subnets)
    print(json.dumps(result))
