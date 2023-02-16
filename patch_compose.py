"""
Patch docker-compose.yml to add volume mapping for testing.
Add -v $COVERAGE_FOLDER:/app/cov
and target=test
to the specified service.
Unexpose all ports.
"""
import sys
import yaml

def patch_compose(target, inputs):
    """Patch docker-compose.yml to add volume mapping for testing."""
    compose = yaml.safe_load(''.join(inputs))
    if 'services' not in compose:
        print("No services found in docker-compose.yml")
        sys.exit(1)
    if target not in compose['services']:
        print(f"Service {target} not found in docker-compose.yml")
        sys.exit(1)
    if 'volumes' not in compose['services'][target]:
        compose['services'][target]['volumes'] = []
    compose['services'][target]['volumes'].append("$COVERAGE_FOLDER:/app/cov")
    compose['services'][target]['build']['target'] = "test"

    # unpublish all ports
    for service in compose['services']:
        if 'ports' in compose['services'][service]:
            new_ports = []
            for p in compose['services'][service]['ports']:
                if ":" in str(p):
                    new_ports.append(p.split(":")[0])
                else:
                    new_ports.append(p)
            compose['services'][service]['ports'] = new_ports

    return yaml.dump(compose, default_flow_style=False)

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print("Usage: patch_compose.py <service>")
        print("Pipe docker-compose.yml to stdin, output to stdout.")
        sys.exit(1)
    target = sys.argv[1]

    inputs = sys.stdin.readlines()
    print(patch_compose(target, inputs))