import subprocess

print("cleaning...")
subprocess.run(["make", "clean"])
print("launching the tb")
subprocess.run(["make"])
