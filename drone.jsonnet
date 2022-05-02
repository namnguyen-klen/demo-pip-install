local run_ansible_step(dryrun=true) = {
  local steps = |||
    echo hello
    echo goodbyes
  |||,

  name: "Echo",
  image: "alpine",
  commands: [steps]
};

local Dryrun(playbook, variable_files) = {
  kind: 'pipeline',
  type: 'docker',
  name: 'ansible-dryrun-' + playbook,
  trigger: {
    'branch': ["IM-*"],
    'event': ["push"],
    'paths': {
      'include': variable_files
    }
  },
  steps: [run_ansible_step(dryrun=true)]
};

local Promote(playbook, variable_files) = {
  kind: 'pipeline',
  type: 'docker',
  name: 'ansible-promote-' + playbook,
  trigger: {
    'target': ["production"],
    'event': ["promote"],
    'paths': {
      'include': variable_files
    }
  },
  steps: [run_ansible_step(dryrun=true)]
};

local Pipeline(playbook, variable_file) = [ 
  Dryrun(playbook, variable_file),
  Promote(playbook, variable_file)
];

Pipeline("install-exporters", "HW0_environment.yaml") +
Pipeline("install-protheus", "HW1_environment.yaml")
