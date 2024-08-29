# -*- coding: utf-8 -*-

import subprocess
import json


def exeute():
	# task_id = 1
	# compnay_task.find(id=1)
	# compnay_task.options
	json_string = '''
	{
	  "network": "localhost",
	  "kind": "1",
	  "kind_summury": "aaa"
	}
	'''

	json_dict = json.loads(json_string)

	print(json_dict['network'])
	print(json_dict['kind'])
	# create tresury
	if json_dict['kind'] == '1':
		print("create tresury")
		# cmd = 'npx hardhat run deploy_sample.js --network {}'.format({json_dict["network"]})
		#　TODO コマンド出力
		# TODO try catch
		# subprocess.call(cmd.split())

        # deploy_ERC20VotesToken.js deploy_sample.js
		cp = subprocess.run(["npx", "hardhat", "run", "deploy_sample.js", "--network", "localhost"], encoding='utf-8', stdout=subprocess.PIPE)
		# if cp.returncode == 0 

		#print(cp.returncode.__class__.__name__)
		#print(cp.stdout.__class__.__name__)
		data = {"returncod": cp.returncode, "stdout": cp.stdout}
		print(data)
		# call request
		# return  code
		# /api/ccontracts_logs post network   {type: 'deploy', address: 'asreaweaeawea', name: 'OpenJpDaoGovernor' o} 
	



	# cms = "npx hardhat run "

	# cmd = "npx hardhat run deploy_ERC20VotesToken.js --network localhost"
	# subprocess.call(cmd.split())

if __name__ == '__main__':
	exeute()
