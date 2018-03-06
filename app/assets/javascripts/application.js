// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require trix
//= require rails-ujs
//= require_tree .

(function() {
  const application = Stimulus.Application.start()  
  application.register("clipboard", class extends Stimulus.Controller {
    connect() {
      if (document.queryCommandSupported("copy")) {
        this.element.classList.add("clipboard--supported")
      }
    }
    copy() {
      const target = this.targets.find("source")
      target.select()
      document.execCommand("copy")
    }
  })
  
  application.register("dropdown", class extends Stimulus.Controller {
    open() {
      const target = this.targets.find("menu")
      target.classList.remove("hidden")
      target.classList.add("visible")
    }    
    close() {
      const target = this.targets.find("menu")
      target.classList.remove("visible")
      target.classList.add("hidden")
    }
  })
  
  application.register("autocomplete", class extends Stimulus.Controller {
    enter(event) {
      var char = document.getElementById('dropdown_list').getElementsByClassName("item selected")[0].getAttribute('data-char');
      insertText(event.srcElement.getAttribute('data-value'), event.srcElement.getAttribute('data-type'), char);
    }    
  })
  
  application.register("search", class extends Stimulus.Controller {
    fire() {
      const username = this.element.getAttribute("data-username")
      if (username != "") {
        var query = "/" + username
      } else {
        var query = username
      }
      const target = this.targets.find("field")
      if (event.which == 13) {
        var term = target.value //.trim()
        if (term[0] == "#") {
          location.href = query + "/tags" + term.replace(/\s/g, "").replace(/#/g,"/");
        } else {
          location.href = query +  "/search/" + term;
        }
      }
    }
  })
})()

// avoid pasting images from other sources
addEventListener("trix-attachment-add", function(event) {
  if (!event.attachment.file) {
    event.attachment.remove()
  }
})

addEventListener("trix-change", function(event) {
    trix = event.target;
    var doc = trix.editor.getDocument().toString();
    var pos = trix.editor.getSelectedRange();
    var d = document.getElementById('dropdown_list').getElementsByClassName("item selected")[0];
    if (dropdownActive()) {
      var trigger = d.getAttribute('data-trigger');
      i = 1;
      var pos_check = doc.charAt(pos[1] - i);
      var collect_char = []
      while (trigger != pos_check) {
        pos_check = doc.charAt(pos[1] - i);
        collect_char.push(pos_check);
        i++;
      }
      var char = collect_char.reverse().slice(1).join("");
    } else {
      var trigger = doc.charAt(pos[1] - 2);
      var char = doc.charAt(pos[1] - 1);
    }
    var d = document.getElementById('tags_dropdown');
    hideDropdown();
    if (char.length > 0) {
      if (trigger == "#") {
        buildDropdown(char, "/search/tags", trigger);
      } else if (trigger == ":") {
        buildDropdown(char, "/search/emoji", trigger)
      } else if (trigger == "@") {
        buildDropdown(char, "/search/users", trigger);
      }
    }
})

addEventListener('keydown', function(e) {
  if (dropdownActive()) {
    var d = document.getElementById('dropdown_list');
    var selected = d.getElementsByClassName("item selected")[0];
    switch (e.keyCode) {
    case 38: // up
        var prev = selected.previousElementSibling;
        if (prev != null) {
          selected.classList.remove("selected");
          prev.classList.add("selected");
        }
        e.preventDefault();
        break;
      case 40: // down
        var next = selected.nextElementSibling;
        if (next != null) {
          selected.classList.remove("selected");
          next.classList.add("selected");
        }
        e.preventDefault();
        break;
      case 13: // enter
        e.preventDefault();
        e.stopPropagation();
        var value = selected.getAttribute('data-value');
        var type = selected.getAttribute('data-type');
        var char = selected.getAttribute('data-char');
        insertText(value, type, char);
        break;
      case 27: // esc
        hideDropdown();
        e.preventDefault();
        break;
      } 
  }
})

function showDropdown(d, trix) {
  rect = trix.editor.getClientRectAtPosition(trix.editor.getPosition());
  d.style.position = "absolute";
  d.style.left = rect.x +'px';
  d.style.top = (rect.y + 20) +'px';
  d.children[0].classList.remove("hidden");
  d.children[0].classList.add("visible");
}

function dropdownActive() {
  var d = document.getElementById('tags_dropdown');
  if (d && d.children[0].className.indexOf("visible") != -1) {
    return true;
  }
  else {
    return false;
  }
}

function hideDropdown() {
  var d = document.getElementById('tags_dropdown').children[0];
  if (d.className.indexOf("visible") != -1) {
    d.classList.remove("visible");
    d.classList.add("hidden");
    d.innerHTML = "";
  }
}

function insertText(str, type, char) {
  var editor = document.querySelector("trix-editor").editor;
  var current = editor.getSelectedRange();
  if (type.indexOf("emoji") != -1) {
    editor.setSelectedRange([current[0]-char.length,current[0]]);
    editor.deleteInDirection("backward");
  } else {
    editor.setSelectedRange([current[0]-char.length,current[0]]);
  }
  editor.deleteInDirection("backward");
  editor.insertString(str);
  hideDropdown();
}

function buildDropdown(char, url, trigger) {
  Rails.ajax({
    url: url,
    type: "POST",
    data: "query=" + char,
    success: function(data) {
      var tags = data;
      var first = false;
      for(var i = 0; i < tags.length; i++){
        if (url.indexOf("emoji") != -1) {
          var tag = tags[i][0];
          var image = tags[i][1];
        } else {
          var tag = tags[i];
        } 
        if (tag.substring(0, char.length) == char) {
          var link = "<a class='item";
          if (!first) {
            link += " selected";
            first = true;
          } 
          if (image) {
            link += "' style='text-decoration:none;' data-char='" + char + "' data-trigger='" + trigger + "' data-type='emoji' data-value='" + image + "' data-action='autocomplete#enter' data-target='autocomplete.source'>" +  image + " ";
          } else {
            link += "' style='text-decoration:none;' data-char='" + char + "' data-trigger='" + trigger + "' data-type='text' data-value='" + tag + "' data-action='autocomplete#enter' data-target='autocomplete.source'>";
          }      
          link += tag + "</a>";
          document.getElementById('tags_dropdown').children[0].innerHTML += link;
          showDropdown(document.getElementById('tags_dropdown'), document.querySelector("trix-editor"));
        }
      }
    }
  });
}
