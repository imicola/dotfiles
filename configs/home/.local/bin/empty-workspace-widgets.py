#!/usr/bin/env python3
"""Drive Noctalia desktop widget visibility from Niri's event stream."""
import json,subprocess,selectors,os,time
from pathlib import Path
class Model:
 def __init__(self):self.workspaces={};self.windows={};self.have_ws=False;self.have_windows=False;self.overview=False
 def update(self,event):
  if 'WorkspacesChanged' in event:self.workspaces={w['id']:w for w in event['WorkspacesChanged']['workspaces']};self.have_ws=True
  elif 'WindowsChanged' in event:self.windows={w['id']:w for w in event['WindowsChanged']['windows']};self.have_windows=True
  elif 'WorkspaceActivated' in event:
   w=self.workspaces.get(event['WorkspaceActivated']['id'])
   if w:
    for v in self.workspaces.values():
     if v.get('output')==w.get('output'):v['is_active']=v['id']==w['id']
  elif 'WindowOpenedOrChanged' in event:
   w=event['WindowOpenedOrChanged']['window'];self.windows[w['id']]=w
  elif 'WindowClosed' in event:self.windows.pop(event['WindowClosed']['id'],None)
  elif 'OverviewOpenedOrClosed' in event:self.overview=event['OverviewOpenedOrClosed']['is_open']
 def visible(self):
  if not self.have_ws or not self.have_windows or self.overview:return False
  ws=next((w for w in self.workspaces.values() if w.get('output')=='eDP-1' and w.get('is_active')),None)
  return ws is not None and not any(w.get('workspace_id')==ws['id'] for w in self.windows.values())
def main():
 model=Model();last=None;retry=0;status=Path(os.environ.get('XDG_RUNTIME_DIR','/run/user/1000'))/'hydrangea-widgets-status.json'
 proc=subprocess.Popen(['niri','msg','-j','event-stream'],stdout=subprocess.PIPE,bufsize=0)
 sel=selectors.DefaultSelector();sel.register(proc.stdout,selectors.EVENT_READ);buffer=b''
 try:
  while proc.poll() is None:
   events=sel.select(timeout=1 if retry else None)
   for key,_ in events:
    chunk=os.read(key.fileobj.fileno(),65536)
    if not chunk:return
    buffer+=chunk
    while b'\n' in buffer:
     line,buffer=buffer.split(b'\n',1)
     try:model.update(json.loads(line))
     except (ValueError,KeyError,TypeError):continue
   desired=model.visible()
   if desired!=last and time.monotonic()>=retry:
    r=subprocess.run(['noctalia','msg','desktop-widgets-show' if desired else 'desktop-widgets-hide'],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL,timeout=4)
    if r.returncode==0:
     last=desired;retry=0;status.write_text(json.dumps({'visible':desired,'reason':'empty workspace' if desired else 'window present, overview, or state pending'}));print('Widgets visible:',desired,flush=True)
    else:retry=time.monotonic()+1
 finally:
  proc.terminate();proc.wait(timeout=3)
if __name__=='__main__':main()
