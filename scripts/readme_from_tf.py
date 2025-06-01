import hcl2
import os
import sys

def parse_variables_tf(filepath):
    with open(filepath, 'r') as file:
        parsed = hcl2.load(file)

    variables = parsed.get("variable", {})
    result = []

    for var in variables:
        for name, attrs in var.items():
            type_ = attrs.get("type", "string")
            default = attrs.get("default", "—")
            desc = attrs.get("description", "—")

            # Clean default
            if isinstance(default, (dict, list)):
                default = f"`{default}`"
            elif isinstance(default, str):
                default = f"`{default}`"
            elif default == "—":
                pass
            else:
                default = f"`{default}`"

            result.append({
                "name": name,
                "type": type_,
                "default": default,
                "description": desc
            })

    return result

def parse_outputs_tf(filepath):
    with open(filepath, 'r') as file:
        parsed = hcl2.load(file)

    outputs = parsed.get("output", {})
    result = []

    for out in outputs:
        for name, attrs in out.items():
            desc = attrs.get("description", "—")
            value = attrs.get("value", "—")

            result.append({
                "name": name,
                "description": desc,
                "value": f"`{value}`" if isinstance(value, str) else value
            })

    return result

def outputs_to_markdown_table(outputs):
    lines = []
    lines.append("| Name | Description |")
    lines.append("|------|-------------|")
    for out in outputs:
        lines.append(f"| `{out['name']}` | {out['description']} |")
    return "\n".join(lines)

def to_markdown_table(variables):
    lines = []
    lines.append("| Name | Description | Default | Type |")
    lines.append("|------|-------------|---------|------|")
    for var in variables:
        lines.append(f"| `{var['name']}` | {var['description']} | {var['default']} | {var['type']} |")
    return "\n".join(lines)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python generate_md_from_tfvars.py <module_path>")
        sys.exit(1)

    module_path = sys.argv[1]
    filepath = os.path.join(module_path, "variables.tf")

    if not os.path.exists(filepath):
        print(f"Error: {filepath} not found.")
        sys.exit(1)

    variables = parse_variables_tf(filepath)
    print("\n## Inputs\n")
    print(to_markdown_table(variables))

    outputs_path = os.path.join(module_path, "outputs.tf")
    if os.path.exists(outputs_path):
        outputs = parse_outputs_tf(outputs_path)
        print("\n## Outputs\n")
        print(outputs_to_markdown_table(outputs))
    else:
        print("\nNo outputs.tf file found.")
