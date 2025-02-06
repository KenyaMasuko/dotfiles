"use strict";var T=Object.create;var g=Object.defineProperty;var B=Object.getOwnPropertyDescriptor;var J=Object.getOwnPropertyNames;var W=Object.getPrototypeOf,M=Object.prototype.hasOwnProperty;var X=(e,n)=>{for(var r in n)g(e,r,{get:n[r],enumerable:!0})},L=(e,n,r,l)=>{if(n&&typeof n=="object"||typeof n=="function")for(let a of J(n))!M.call(e,a)&&a!==r&&g(e,a,{get:()=>n[a],enumerable:!(l=B(n,a))||l.enumerable});return e};var y=(e,n,r)=>(r=e!=null?T(W(e)):{},L(n||!e||!e.__esModule?g(r,"default",{value:e,enumerable:!0}):r,e)),j=e=>L(g({},"__esModule",{value:!0}),e);var G={};X(G,{default:()=>R,useLocalExtensions:()=>v});module.exports=j(G);var o=require("@raycast/api"),p=require("react");var $=require("@raycast/api"),h=y(require("fs"));function I(e){return e instanceof Error?e.message:"unknown error"}async function w(e){return h.promises.access(e,h.constants.F_OK).then(()=>!0).catch(()=>!1)}var Y=new Intl.NumberFormat("en",{notation:"compact"});var S=y(require("fs/promises")),O=y(require("os")),u=y(require("path")),F=y(require("child_process"));function _(e){if(!e)return e;let n=e.match(/%(.+)%/);if(n)return n[1]}function V(){return"/Applications/Cursor.app/Contents/Resources/app/bin/cursor"}var b=class{constructor(n){this.cliFilename=n}installExtensionByIDSync(n){F.execFileSync(this.cliFilename,["--install-extension",n,"--force"])}uninstallExtensionByIDSync(n){F.execFileSync(this.cliFilename,["--uninstall-extension",n,"--force"])}};function U(){return new b(V())}async function q(e){try{if(await w(e)){let n=await S.readFile(e,{encoding:"utf-8"}),r=JSON.parse(n),l=r.displayName,a=_(l),i=r.icon,c=u.default.dirname(e);if(a&&a.length>0){let f=u.default.join(c,"package.nls.json");try{if(await w(f)){let x=await S.readFile(f,{encoding:"utf-8"}),D=JSON.parse(x)[a];D&&D.length>0&&(l=D)}}catch{}}let m=r.preview,d=i?u.default.join(c,i):void 0;return{displayName:l,icon:d,preview:m}}}catch{}}async function A(){let e=u.default.join(O.homedir(),".cursor/extensions"),n=u.default.join(e,"extensions.json");if(await w(n)){let r=await S.readFile(n,{encoding:"utf-8"}),l=JSON.parse(r);if(l&&l.length>0){let a=[];for(let i of l){let c=typeof i.location=="string"?u.default.join(e,i.location):i.location.fsPath??i.location.path,m=u.default.join(c,"package.json"),d=await q(m);a.push({id:i.identifier.id,name:d?.displayName||i.identifier.id,version:i.version,preRelease:i.metadata?.preRelease,icon:d?.icon,updated:i.metadata?.updated,fsPath:c,publisherId:i.metadata?.publisherId,publisherDisplayName:i.metadata?.publisherDisplayName,preview:d?.preview,installedTimestamp:i.metadata?.installedTimestamp})}return a}}}var t=require("@raycast/api");var k=require("react/jsx-runtime");function C(e){return(0,k.jsx)(t.Action,{onAction:async()=>{try{await(0,t.confirmAlert)({title:"Uninstall Extension?",icon:{source:t.Icon.Trash,tintColor:t.Color.Red},primaryAction:{style:t.Alert.ActionStyle.Destructive,title:"Uninstall"}})&&(await(0,t.showToast)({style:t.Toast.Style.Animated,title:"Install Extension"}),U().uninstallExtensionByIDSync(e.extensionID),await(0,t.showToast)({style:t.Toast.Style.Success,title:"Uninstall Successful"}),e.afterUninstall&&e.afterUninstall())}catch(r){(0,t.showToast)({style:t.Toast.Style.Failure,title:"Error",message:I(r)})}},title:"Uninstall Extension",icon:{source:t.Icon.Trash,tintColor:t.Color.Red}})}function N(e){return(0,k.jsx)(t.Action.OpenInBrowser,{title:"Open in Cursor",url:`cursor:extension/${e.extensionID}`,icon:"icon.png",onOpen:n=>{(0,t.showHUD)("Open Cursor Extension"),e.onOpen&&e.onOpen(n)}})}function P(e){let n=`https://marketplace.visualstudio.com/items?itemName=${e.extensionID}`;return(0,k.jsx)(t.Action.OpenInBrowser,{title:"Open in Browser",url:n,shortcut:{modifiers:["cmd"],key:"b"},onOpen:()=>{(0,t.showHUD)("Open Cursor Extension in Browser")}})}var s=require("react/jsx-runtime");function H(e){return(0,s.jsx)(N,{extensionID:e.extension.id})}function K(e){return(0,s.jsx)(P,{extensionID:e.extension.id})}function z(e){let n=e.extension;return(0,s.jsx)(o.List.Item,{title:n.name,subtitle:n.publisherDisplayName,icon:{source:n.icon||"icon.png",fallback:"icon.png"},accessories:[{tag:n.preview===!0?{color:o.Color.Red,value:"Preview"}:""},{tag:n.version,tooltip:n.installedTimestamp?`Installed:  ${new Date(n.installedTimestamp).toLocaleString()}`:""}],actions:(0,s.jsxs)(o.ActionPanel,{children:[(0,s.jsxs)(o.ActionPanel.Section,{children:[(0,s.jsx)(H,{extension:n}),(0,s.jsx)(K,{extension:n})]}),(0,s.jsxs)(o.ActionPanel.Section,{children:[(0,s.jsx)(o.Action.CopyToClipboard,{content:n.id,title:"Copy Extension Id",shortcut:{modifiers:["cmd","shift"],key:"."}}),n.publisherDisplayName&&(0,s.jsx)(o.Action.CopyToClipboard,{content:n.publisherDisplayName,title:"Copy Publisher Name",shortcut:{modifiers:["cmd","shift"],key:","}}),(0,s.jsx)(o.Action.Open,{title:"Open in Finder",target:n.fsPath,shortcut:{modifiers:["cmd","shift"],key:"f"}})]}),(0,s.jsx)(o.ActionPanel.Section,{children:(0,s.jsx)(C,{extensionID:n.id,afterUninstall:e.reloadExtension})})]})})}function R(){let{extensions:e,isLoading:n,error:r,refresh:l}=v();r&&(0,o.showToast)({style:o.Toast.Style.Failure,title:"Error",message:r});let a=e?.sort((i,c)=>i.name<c.name?-1:i.name>c.name?1:0);return(0,s.jsx)(o.List,{isLoading:n,searchBarPlaceholder:"Search Installed Extensions",children:(0,s.jsx)(o.List.Section,{title:"Installed Extensions",subtitle:`${a?.length}`,children:a?.map(i=>(0,s.jsx)(z,{extension:i,reloadExtension:l},i.id))})})}function v(){let[e,n]=(0,p.useState)(!0),[r,l]=(0,p.useState)(),[a,i]=(0,p.useState)(),[c,m]=(0,p.useState)(new Date),d=()=>{m(new Date)};return(0,p.useEffect)(()=>{let f=!1;async function x(){if(!f){n(!0),i(void 0);try{let E=await A();f||l(E)}catch(E){f||i(I(E))}finally{f||n(!1)}}}return x(),()=>{f=!0}},[]),{extensions:r,isLoading:e,error:a,refresh:d}}0&&(module.exports={useLocalExtensions});
