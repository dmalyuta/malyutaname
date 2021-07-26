document.addEventListener("DOMContentLoaded", event => {
  // Make non-internal links open in new tab
  document.querySelectorAll('article a').forEach(item => {
    if (!item.classList.contains('internal')) {
      item.setAttribute("target", "_blank");
      item.setAttribute("rel", "noopener noreferrer");
    }
  })

  // Insert the footnotes
  let number_footnotes = document.querySelectorAll('.footnote-mark').length;
  let footnote_content = "";
  let footnote_container = document.querySelector('.footnote-text-container');
  for (let i=1; i<=number_footnotes; i++) {
    let this_footnote = document.querySelector('#footnote-'+i);
    footnote_container.appendChild(this_footnote);
    this_footnote.style.display = "block";
  }

  // Set the figure reference numbers (map label to number)
  document.querySelectorAll('span.figref a').forEach(item => {
    let fig_id = item.getAttribute("href");
    let figure = document.querySelector(fig_id);
    // The next line assumes that the second element of the class list is "figure-#"
    let figure_number = figure.classList[1].split("-")[1];
    item.innerHTML = figure_number;
  })

  // Set equation references
  document.querySelectorAll('.eqlabel').forEach(item => {
    let classes = item.className.split(' ');
    let class_match = classes.find(value => /^eq:/.test(value));
    item.id = class_match;

    let equation_number = classes.find(value => /^equation-/.test(value));
    equation_number = equation_number.split('-')[1];
    let selector = ('.eqreflink.'+class_match).replace(/:/, '\\:');
    document.querySelectorAll(selector).forEach(eqref => {
      let eqref_classes = eqref.className.split(' ');
      eqref.innerHTML = equation_number;
    })
  })

  // Move post navigation bar to appropriate position
  let navbar = document.querySelector('.article-navigation-container');
  let content_area = document.querySelector('.nav-padded-area.top-padded-area');
  content_area.appendChild(navbar);

  // Populate navbar with document sections
  function add_nav_item(list, item, classes="") {
    let text = item.innerText;
    let id = item.id;
    let navitem = '<li class="'+classes+'"><a '
    navitem += 'href="#'+id+'" class="internal">';
    navitem += text+'</a></li>';
    list.innerHTML += navitem;
  }
  let navlist = navbar.querySelector('ul');
  let all_navitems = new Array();
  document.querySelectorAll('article h2').forEach(item => {
    add_nav_item(navlist, item);
    all_navitems.push(navlist.lastChild);

    let elems = $(item).nextUntil('article h2');
    for (let i=0; i<elems.length; i++) {
      let subitem = elems[i].querySelector('.article-subnav-item');
      if (subitem) {
        // Create an ID
        let text = subitem.innerText;
        let id = text.replace(/\W/g,'_');
        subitem.id = id;
        subitem.parentElement.style.margin = "0";
        subitem.parentElement.style.padding = "0";
        subitem.parentElement.style.position = "absolute";

        add_nav_item(navlist, subitem, "subnavitem");
        all_navitems.push(navlist.lastChild);
      }
    }
  });

  // Adjust post width to fit navbar
  let navbar_width = $('.article-navigation-div').width();
  let article_width = $('main').width();
  article_width -= navbar_width;
  $('main').css("width", article_width);

  // Navbar emulate fixed-y
  let navbar_div = $('.article-navigation-container');
  let navbar_p0 = parseInt(navbar_div.css("top"));
  let navbar_top = navbar_div.offset().top;
  $(window).on('load scroll touchmove resize', function() {
    let window_top = $(window).scrollTop();
    let new_navbar_p = navbar_p0+window_top;
    let navbar_top_new = navbar_top+window_top;
    navbar_div.css("top", new_navbar_p);
    // See if current window is "too short" for the update
    let navbar_bot = navbar_top_new+navbar_div.height();
    let article_bot = $("article").offset().top+$("article").height();
    let dy_adjust = article_bot-navbar_bot;
    if (dy_adjust<0) {
      new_navbar_p += dy_adjust;
      navbar_div.css("top", new_navbar_p);
    }
  })

  // Turn off navbar animation onclick, so that menu appears immediately
  document.querySelectorAll('.article-navigation-div ul a').forEach(item => {
    item.addEventListener('click', function () {
      let navbar = document.querySelector(".article-navigation-container");
      original_transitionDelay = getComputedStyle(navbar).getPropertyValue("transition-delay");
      original_transitionDuration = getComputedStyle(navbar).getPropertyValue("transition-duration");
      navbar.style.transitionDelay = "0s";
      navbar.style.transitionDuration = "0s";
      // Restore original values after 100 ms
      setTimeout(function () {
        navbar.style.transitionDelay = original_transitionDelay;
        navbar.style.transitionDuration = original_transitionDuration;
      }, 100);
    });
  })

  // Highlight current section in the navbar
  all_navitems.reverse();
  let navitem_count = all_navitems.length;
  $(window).on('load scroll touchmove resize', function() {
    let windowMidpoint = $(window).height()/2;
    for (let i=0; i<navitem_count; i++) {
      let navitem = all_navitems[i];
      let id = navitem.querySelector('a').href.split('#')[1];
      let section_element = document.querySelector('#'+id);
      var thisTop = $(section_element).offset().top - $(window).scrollTop();
      if (thisTop < windowMidpoint) {
        // Remove any existing "current"
        $(".article-navigation-div ul li").each(function () {
          $(this).removeClass("current");
        });
        // Set "current"
        let actual_navitem = navlist.children.item(navitem_count-1-i);
        $(actual_navitem).addClass("current");
        break;
      }
    }
  })
})
