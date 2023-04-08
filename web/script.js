let player_avatar = "./imgs/wick.webp";
let default_avatar;
let main_menu;
let avatar_history = [];
const possible_formats = ["webp", "png", "jpg", "jpeg", "gif"];
const main = ` <div class="app-container">
<div class="history-btn" id="history">
  <svg
    id="Layer_1"
    data-name="Layer 1"
    xmlns="http://www.w3.org/2000/svg"
    viewBox="0 0 122.88 108.12"
  >
    <title>history</title>
    <path
      d="M28.45,55.88c0,.11,0,.22,0,.32l4.44-4.46a6.68,6.68,0,1,1,9.48,9.42L27.14,76.51a6.69,6.69,0,0,1-9.32.15L2.28,63A6.68,6.68,0,0,1,11.08,53l4,3.54v0a54.33,54.33,0,0,1,8-31,52.56,52.56,0,0,1,24-20.73,60.17,60.17,0,0,1,11-3.51,52.58,52.58,0,0,1,60.1,31.09,58.07,58.07,0,0,1,3.47,11,52.47,52.47,0,0,1-1.31,26.95A53.16,53.16,0,0,1,105.8,93a57.11,57.11,0,0,1-22.56,13.1,48.52,48.52,0,0,1-40.51-5.89A6.68,6.68,0,0,1,50,89a35.12,35.12,0,0,0,5.53,3,34.21,34.21,0,0,0,5.7,1.86,35.43,35.43,0,0,0,18.23-.54A43.77,43.77,0,0,0,96.74,83.19a39.7,39.7,0,0,0,10.93-17.06,39,39,0,0,0,1-20.08,46.38,46.38,0,0,0-2.68-8.5,39.19,39.19,0,0,0-45-23.22,45,45,0,0,0-8.52,2.72A39,39,0,0,0,34.5,32.49a40.94,40.94,0,0,0-6.05,23.39ZM60.83,34a6.11,6.11,0,0,1,12.22,0V53l14.89,8.27A6.09,6.09,0,1,1,82,71.93L64.43,62.16a6.11,6.11,0,0,1-3.6-5.57V34Z"
    />
  </svg>
  <span>History</span>
</div>
<figure class="profile_avatar">
  <img id="avatar" src="imgs/wick.webp" alt="profile" />
  <figcaption>Current Avatar</figcaption>
</figure>

<form action="" onsubmit="UpdateAvatar(event)" class="updateimg-form">
  <input
    type="url"
    id="imglink"
    required
    placeholder="https://imglink.com/img.png"
  />
  <div class="updateimg-actions">
    <button type="submit" class="bg-blue-600">Update</button>
    <button type="button" id="resetbtn" class="bg-neutral-700">
      Reset
    </button>
  </div>
</form>
</div>`;
const historyContent = `<div style="display: none;" id="history-content"

class="flex flex-col items-center gap-2 w-full h-full overflow-y-auto p-1 relative"
>
<div class="relative text-2xl col-span-2 font-bold w-full text-center">
  <button
    type="button"
    id="gotomain"
    class="absolute left-0 top-1/2 -translate-y-1/2 text-sm hover:text-blue-500 ease duration-200"
  >
    👈 Go back
  </button>
  <div>Avatar History</div>
</div>
<div class="avatar-list" id="avatar-list">
</div>
</div>`;

function ToggleVisibility(state) {
  if (state) {
    $("#app").fadeIn(200);
  } else {
    $("#app").fadeOut(200);
  }
}

async function GetAvatarHistory() {
  try {
    const resp = await SendClientMessage("GetAvatarHistory");
    avatar_history = await resp.json();
    const avatarList = document.getElementById("avatar-list");
    avatarList.innerHTML = "";
    await [...avatar_history].reverse().forEach((avatar) => {
      avatarList.innerHTML += `<figure class="avatar-info">
            <img src="${avatar.avatar}" alt="img" />
            <button class="bg-blue-600" id="use-old-avatar">
            Use
            </button>
            <button
            class="bg-neutral-700"
            id="delete-avatar-record"
            time="${avatar.time}"
            >
            Delete
            </button>
            </figure>`;
    });
    return true;
  } catch (e) {
    console.log("Error Getting Avatar History:", e);
  }
}

function UpdateAvatar(e) {
  e.preventDefault();
  const imglink = document.getElementById("imglink")?.value;
  if (typeof imglink !== "string") return;
  const isImage = possible_formats.some((format) => imglink.includes(format));
  if (!isImage) return;
  player_avatar = imglink;
  $("#avatar").attr("src", imglink);
  SendClientMessage("UpdateAvatar", { avatar: imglink });
}

/* NUI */
async function SendClientMessage(event, data = {}) {
  if (typeof event !== "string" || typeof data !== "object")
    throw new Error("Invalid arguments");
  try {
    const resourceName = GetParentResourceName();
    return await fetch(`https://${resourceName}/${event}`, {
      method: "POST",
      headers: {
        "Content-type": "application/json; charset=UTF-8",
      },
      body: JSON.stringify(data),
    });
  } catch (e) {
    console.log(e);
  }
}

/* Event Listners */

window.addEventListener("message", (event) => {
  let type = event.data.type;
  let data = event.data.data;
  if (type == "avatar") {
    player_avatar = data?.avatar;
    $("#avatar").attr("src", player_avatar);
    $("#app").fadeIn(200);
  } else if (type == "open") {
    player_avatar = data?.avatar;
    $("#app").html(main);
    $("#avatar").attr("src", player_avatar);
    ToggleVisibility(true);
  } else if ((type = "default_avatar")) {
    default_avatar = data?.avatar;
  }
});

window.addEventListener("keyup", (event) => {
  if (event.key == "Escape") {
    SendClientMessage("close");
    $("#app").fadeOut(200);
  }
});

window.addEventListener("click", (event) => {
  if (event.target.id == "updateavatarbtn") {
    $.post("http://avatar/update", JSON.stringify({ avatar: player_avatar }));
  } else if (event.target.id === "resetbtn") {
    player_avatar = default_avatar;
    $("#avatar").attr("src", player_avatar);
    SendClientMessage("resetAvatar");
  } else if (event.target.id === "history") {
    const appEl = document.getElementById("app");
    main_menu = appEl.innerHTML;
    appEl.innerHTML = historyContent;
    if (GetAvatarHistory()) $("#history-content").fadeIn(200);
  } else if (event.target.id === "gotomain") {
    $("#app").html(main);
    $(".app-container").css("display", "none");
    $("#avatar").attr("src", player_avatar);
    $(".app-container").fadeIn(200);
  } else if (event.target.id === "delete-avatar-record") {
    // get index attr
    const time = event.target.getAttribute("time");
    avatar_history = avatar_history.filter((avatar) => avatar.time !== time);
    // remove element
    event.target.closest(".avatar-info").remove();
    SendClientMessage("DeleteAvatar", { history: avatar_history });
  } else if (event.target.id === "use-old-avatar") {
    const img = event.target.previousElementSibling.getAttribute("src");
    player_avatar = img;
    $("#avatar").attr("src", img);
    SendClientMessage("UseOldAvatar", { avatar: img });
  }
});
