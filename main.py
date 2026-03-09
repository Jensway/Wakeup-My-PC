# wol.py
import tkinter as tk
from tkinter import messagebox
import paramiko
import threading
import concurrent.futures
import subprocess
import socket
import re

def wake():
    ip = entry_ip.get().strip()
    pwd = entry_pwd.get().strip()
    mac = entry_mac.get().strip()

    if not ip or not pwd or not mac:
        messagebox.showwarning("提示", "请填写所有字段")
        return

    if not re.match(r"^([0-9A-Fa-f]{2}[:-]){5}[0-9A-Fa-f]{2}$", mac):
        messagebox.showwarning("提示", "MAC 地址格式不正确")
        return

    btn.config(text="唤醒中...", bg="#555555", state="disabled")

    def connect_via_paramiko():
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        try:
            ssh.connect(ip, username="root", password=pwd, timeout=15, look_for_keys=False, allow_agent=False)
            _, _, stderr = ssh.exec_command(f"etherwake -i br-lan {mac}")
            err = stderr.read().decode().strip()
            ssh.close()
            return {"success": not err, "error": err, "component": "Paramiko SSH"}
        except Exception as e:
            try:
                ssh.close()
            except:
                pass
            return {"success": False, "error": str(e), "component": "Paramiko SSH"}

    def connect_via_subprocess():
        try:
            result = subprocess.run(
                [
                    "ssh",
                    "-o", "StrictHostKeyChecking=no",
                    "-o", "UserKnownHostsFile=/dev/null",
                    "-o", "ConnectTimeout=15",
                    "-o", "PasswordAuthentication=yes",
                    f"root@{ip}",
                    f"etherwake -i br-lan {mac}"
                ],
                input=pwd.encode(),
                capture_output=True,
                timeout=20
            )
            err = result.stderr.decode().strip()
            return {"success": result.returncode == 0, "error": err, "component": "系统 SSH"}
        except Exception as e:
            return {"success": False, "error": str(e), "component": "系统 SSH"}

    def connect_via_socket_paramiko():
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(15)
            sock.connect((ip, 22))

            transport = paramiko.Transport(sock)
            transport.connect(username="root", password=pwd)

            channel = transport.open_session()
            channel.exec_command(f"etherwake -i br-lan {mac}")
            err = channel.recv_stderr(4096).decode().strip()
            channel.close()
            transport.close()
            sock.close()
            return {"success": not err, "error": err, "component": "Socket+Paramiko"}
        except Exception as e:
            try:
                sock.close()
            except:
                pass
            return {"success": False, "error": str(e), "component": "Socket+Paramiko"}

    def connect_via_telnet():
        try:
            import telnetlib
            tn = telnetlib.Telnet(ip, 23, timeout=15)
            tn.read_until(b"login: ", timeout=10)
            tn.write(b"root\n")
            tn.read_until(b"Password: ", timeout=10)
            tn.write(pwd.encode() + b"\n")
            tn.read_until(b"#", timeout=10)
            tn.write(f"etherwake -i br-lan {mac}\n".encode())
            tn.write(b"exit\n")
            output = tn.read_all().decode()
            tn.close()
            return {"success": True, "error": "", "component": "Telnet"}
        except Exception as e:
            return {"success": False, "error": str(e), "component": "Telnet"}

    def run():
        components = [connect_via_paramiko, connect_via_subprocess, connect_via_socket_paramiko, connect_via_telnet]

        with concurrent.futures.ThreadPoolExecutor(max_workers=4) as executor:
            futures = {executor.submit(fn): fn for fn in components}
            results = []
            for future in concurrent.futures.as_completed(futures):
                result = future.result()
                results.append(result)
                if result["success"]:
                    break

        success = [r for r in results if r["success"]]
        if success:
            root.after(0, lambda: messagebox.showinfo("成功", f"唤醒包已发送！电脑正在开机\n\n通过: {success[0]['component']}"))
        else:
            error_msg = "\n".join([f"[{r['component']}] {r['error']}" for r in results])
            root.after(0, lambda: messagebox.showerror("连接失败", f"所有组件均失败：\n\n{error_msg}"))

        root.after(0, lambda: btn.config(text="立即唤醒", bg="#0078d7", state="normal"))

    threading.Thread(target=run, daemon=True).start()


# ===== GUI =====
root = tk.Tk()
root.title("网络唤醒工具")
root.geometry("380x280")
root.resizable(False, False)
root.configure(bg="#1e1e1e")

font_label = ("Microsoft YaHei UI", 10)
font_entry = ("Consolas", 11)
font_btn = ("Microsoft YaHei UI", 11, "bold")

frame = tk.Frame(root, bg="#1e1e1e", padx=20, pady=15)
frame.pack(fill="both", expand=True)

tk.Label(frame, text="路由器 IP：", font=font_label, fg="white", bg="#1e1e1e").grid(row=0, column=0, sticky="e", pady=6)
entry_ip = tk.Entry(frame, font=font_entry, width=22, bg="#2d2d2d", fg="white", insertbackground="white", relief="flat")
entry_ip.grid(row=0, column=1, pady=6, ipady=3)
entry_ip.insert(0, "192.168.1.1")

tk.Label(frame, text="路由器密码：", font=font_label, fg="white", bg="#1e1e1e").grid(row=1, column=0, sticky="e", pady=6)
entry_pwd = tk.Entry(frame, font=font_entry, width=22, show="*", bg="#2d2d2d", fg="white", insertbackground="white", relief="flat")
entry_pwd.grid(row=1, column=1, pady=6, ipady=3)

tk.Label(frame, text="目标 MAC：", font=font_label, fg="white", bg="#1e1e1e").grid(row=2, column=0, sticky="e", pady=6)
entry_mac = tk.Entry(frame, font=font_entry, width=22, bg="#2d2d2d", fg="white", insertbackground="white", relief="flat")
entry_mac.grid(row=2, column=1, pady=6, ipady=3)

btn = tk.Button(frame, text="立即唤醒", font=font_btn, bg="#0078d7", fg="white", activebackground="#005fa3",
                activeforeground="white", relief="flat", cursor="hand2", width=18, height=1, command=wake)
btn.grid(row=3, column=0, columnspan=2, pady=18)

root.mainloop()