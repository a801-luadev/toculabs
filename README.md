# Tocu Laboratories

 This is the code of the semi-official Transformice module **#toculabs**. It is used to test and publish useful stuff. An example, is the `room-gateway` script, which is currently in use in the `youtube` submode, hosted at **#toculabs0youtube**.

## How does the code run in Transformice?
 As you can see, here it is splitted in different files to make the development easier and organized. Before sending it to Transformice, we need to turn it into a single file. This process is called building and is automatically done via a Github workflow everytime we push something with the `[build]` keyword in a commit. You can find the latest build [here](builds/latest.lua), or you might also check older builds [here](builds). After it is built, if the commit has a `[host]` keyword it will also host it in Transformice. You can check the hosted build [here](builds/hosted.lua).<br>
 <br>
 You can also check our builder [here](builder.py) and our hoster [here](hoster.py). Remember it runs along with a workflow that is [here](.github/workflows/build_host.yml). Our builder follows the instructions of the [init.lua script](init.lua), specified with tags. Currently there is a single tag with many variations (`require-file`, `require-dir`, `require-package`). If you require a package like `modes/youtube`, it'll read `modes/youtube/package.json` and execute its content as tags.

## Can I host something here too?
 Of course you can. Feel free to fork the repository, add your own submode and once you're done, create a pull request. If it requires to run a bot you will need to host it yourself (or use [heroku.com](https://heroku.com/)), but you will need to post the source code of it [here](bots). Remember to use environment variables for your credentials and sensitive data!<br>
 You can also use tools listed here, such as `room-gateway.lua`, located [here](tech/room-gateway).<br>
 You can do the same if you want to translate anything. Find all the translations [here](translations).

## How is the repository structure?
 In the [builds directory](builds) you'll find all the module builds.<br>
 In the [bots directory](bots) you'll find all the bots used for the module.<br>
 In the [global directory](global) you'll find essential scripts used on the whole module.<br>
 In the [modes directory](modes) you'll find all the module modes.<br>
 In the [tech directory](tech) you'll find useful libraries.<br>
 In the [translations directory](translations) you'll find the module translations.<br>
 The [builder.py file](builder.py) is what we use to build the module.<br>
 The [hoster.py file](hoster.py) is what we use to host the module ingame.<br>
 The [init.lua file](init.lua) is the main file containing most of the build instructions.<br>
 The [Procfile file](Procfile) is a file to host the bots in heroku.<br>
 The [requirements.txt file](requirements.txt) contains all the python requirements for the bots.<br>
 <br>
 You will find `README.md` files containing information of where you are inside most of the directories.

## I've found a bug in the module. What can I do?
 You can create an issue in this repository.

## Contributors
 These are all the contributors:

 <table>
  <tr>
    <td align="center"><a href="https://github.com/Tocutoeltuco"><img src="https://avatars2.githubusercontent.com/u/24902450?v=4" width="100px;" alt="Iván"/><br /><sub><b>Iván</b></sub></a><br /><a href="#projectManagement-Tocutoeltuco" title="Project Management">📆</a> <a href="#infra-Tocutoeltuco" title="Infrastructure (Hosting, Build-Tools, etc)">🚇</a> <a href="https://github.com/a801-luadev/toculabs/commits?author=Tocutoeltuco" title="Code">💻</a> <a href="https://github.com/a801-luadev/toculabs/commits?author=Tocutoeltuco" title="Tests">⚠️</a> <a href="#ideas-Tocutoeltuco" title="Ideas, Planning, & Feedback">🤔</a> <a href="#translation-Tocutoeltuco" title="Translation">🌎</a></td>
    <td align="center"><a href="http://bit.ly/laut-id"><img src="https://avatars2.githubusercontent.com/u/26045253?v=4" width="100px;" alt="Lautenschlager"/><br /><sub><b>Lautenschlager</b></sub></a><br /><a href="#infra-Lautenschlager-id" title="Infrastructure (Hosting, Build-Tools, etc)">🚇</a> <a href="https://github.com/a801-luadev/toculabs/commit/129c8319999496cd8f6db00a4769ef88c7c04420" title="Translation">🌎</a></td>
    <td align="center"><a href="https://github.com/b1sergiu"><img src="https://avatars2.githubusercontent.com/u/25414803?v=4" width="100px;" alt="Sergiu Bucur"/><br /><sub><b>Sergiu Bucur</b></sub></a><br /><a href="https://github.com/a801-luadev/toculabs/commit/22de637cea33a67fae427ae7b515dfd4e3548321" title="Translation">🌎</a></td>
    <td align="center"><a href="https://github.com/Danielthemouse"><img src="https://avatars2.githubusercontent.com/u/54555281?v=4" width="100px;" alt="Daniel"/><br /><sub><b>Daniel</b></sub></a><br /><a href="https://github.com/a801-luadev/toculabs/commit/1782e1cd6c74b75e02fe7278f4ff14e0dbc20b22" title="Translation">🌎</a></td>
  </tr>
 </table>
