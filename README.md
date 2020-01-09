# Tocu Laboratories

 This is the code of the semi-official Transformice module **#toculabs**. It is used to test and publish useful stuff. An example, is the `room-gateway` script, which is currently in use in the `youtube-searcher` submode, hosted at **#toculabs0youtube**.

## How does the code run in Transformice?
 As you can see, here it is splitted in different files to make the development easier and organized. Before sending it to Transformice, we need to turn it into a single file. This process is called building and is automatically done via a Github workflow everytime we push something with the [build] keyword in a commit. You can find the latest build [here](builds/latest.lua), or you might also check older builds [here](builds). After it is built, if the commit has a [host] keyword it will also host it in transformice. You can check the hosted build [here](builds/hosted.lua)

 You can also check our builder [here](builder.py) and our hoster [here](hoster.py). Remember it runs along with a workflow that is [here](.github/workflows/build_host.yml). Our builder follows the instructions of the [init.lua script](init.lua), specified with tags. Currently there is a single tag (`require`).

## Can I host something here too?
 Of course you can. Feel free to fork the repository, add your own submode and once you're done, create a pull request. If it requires to run a bot you will need to host it yourself (or use [heroku.com](https://heroku.com/)). You can also use tools listed here, such as `room-gateway.lua`, located [here](youtube-searcher/room-gateway.lua).
 You can do the same if you want to translate anything. Find all the translations [here](translations).
 Remember that adding/removing a file requires to update it in the [init.lua script](init.lua).

## I've found a bug in the module. What can I do?
 You can create an issue in this repository.

## Contributors
 These are all the contributors:

 <table>
  <tr>
    <td align="center"><a href="https://github.com/Tocutoeltuco"><img src="https://avatars2.githubusercontent.com/u/24902450?v=4" width="100px;" alt="Iván"/><br /><sub><b>Iván</b></sub></a><br /><a href="#projectManagement-Tocutoeltuco" title="Project Management">📆</a> <a href="#infra-Tocutoeltuco" title="Infrastructure (Hosting, Build-Tools, etc)">🚇</a> <a href="https://github.com/a801-luadev/toculabs/commits?author=Tocutoeltuco" title="Code">💻</a> <a href="https://github.com/a801-luadev/toculabs/commits?author=Tocutoeltuco" title="Tests">⚠️</a> <a href="#ideas-Tocutoeltuco" title="Ideas, Planning, & Feedback">🤔</a></td>
    <td align="center"><a href="http://bit.ly/laut-id"><img src="https://avatars2.githubusercontent.com/u/26045253?v=4" width="100px;" alt="Lautenschlager"/><br /><sub><b>Lautenschlager</b></sub></a><br /><a href="#infra-Lautenschlager-id" title="Infrastructure (Hosting, Build-Tools, etc)">🚇</a></td>
    <td align="center"><a href="https://github.com/b1sergiu"><img src="https://avatars2.githubusercontent.com/u/25414803?v=4" width="100px;" alt="Sergiu Bucur"/><br /><sub><b>Sergiu Bucur</b></sub></a><br /><a href="https://github.com/a801-luadev/toculabs/commit/22de637cea33a67fae427ae7b515dfd4e3548321" title="Translation">🌍</a></td>
  </tr>
 </table>
