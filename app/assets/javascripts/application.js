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
      var tag = event.srcElement.innerHTML;
      var trix = document.querySelector("trix-editor");
      var current = trix.editor.getSelectedRange();
      trix.editor.setSelectedRange([current[0]-1,current[1]])
      trix.editor.deleteInDirection("forward")
      trix.editor.insertString(tag);
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

document.onkeydown = function(e) {
  switch (e.keyCode) {
    case 38:
      var d = document.getElementById('dropdown_list');
      var selected = d.getElementsByClassName("item selected")[0];
      var prev = selected.previousElementSibling
      if (prev != null) {
        selected.classList.remove("selected")
        prev.classList.add("selected")
      }
      event.preventDefault()
      break;
    case 40:
      var d = document.getElementById('dropdown_list');
      var selected = d.getElementsByClassName("item selected")[0];
      var next = selected.nextElementSibling
      if (next != null) {
        selected.classList.remove("selected")
        next.classList.add("selected")
      }
      event.preventDefault()
      break;
    case 13:
      var d = document.getElementById('dropdown_list');
      var tag = d.getElementsByClassName("item selected")[0].innerHTML;
      var trix = document.querySelector("trix-editor");
      var current = trix.editor.getSelectedRange();
      trix.editor.setSelectedRange([current[0]-1,current[1]])
      trix.editor.deleteInDirection("forward")
      trix.editor.insertString(tag);
      event.preventDefault()
      break;
    case 27:
      hideTagsDropdown();
      event.preventDefault()
      break;
    }
};

addEventListener("trix-change", function(event) {
    trix = event.target;
    var doc = trix.editor.getDocument().toString();
    var pos = trix.editor.getSelectedRange();
    var trigger = doc.charAt(pos[1] - 2);
    var char = doc.charAt(pos[1] - 1);
    var tags = document.getElementById("user_tags").innerHTML.split(",");
    var d = document.getElementById('tags_dropdown');
    
    hideTagsDropdown();
    
    if (trigger == "#") {
      rect = trix.editor.getClientRectAtPosition(trix.editor.getPosition());
      d.style.position = "absolute";
      d.style.left = rect.x +'px';
      d.style.top = (rect.y + 20) +'px';
      d.children[0].classList.remove("hidden");
      d.children[0].classList.add("visible");
      var first = false;
      for(var i = 0; i < tags.length; i++){
        var tag = tags[i];
        if (tag.charAt(0) == char) {
          var link = "<a class='item";
          if (!first) {
            link += " selected";
            first = true;
          } 
          link += "' style='text-decoration:none;' data-action='autocomplete#enter' data-target='autocomplete.source'>"+ tag + "</a>";
          d.children[0].innerHTML += link;
        }
      }
    }
})

function hideTagsDropdown() {
  var d = document.getElementById('tags_dropdown');
  if (d.children[0].className.indexOf("visible") != -1) {
    d.children[0].classList.remove("visible");
    d.children[0].classList.add("hidden");
    d.children[0].innerHTML = "";
  }
}

