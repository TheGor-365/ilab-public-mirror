/* Random decorative shapes on cards/white blocks.
   — исключаем стеклянные панели, оффканвасы и т.п. (НО не модалки)
   — избегаем одинаковых фигур у соседей под одним родителем
   — учитываем Turbo (перерисовки) и динамические вставки
*/

const SHAPES     = [1,2,3,4,5,6,7,8];
const POSITIONS  = ["tl","tr","bl","br","tc","bc","cl","cr"];
const SIZES      = ["sm","md","lg","xl"];
const ROTATIONS  = ["a","b","c","d","e","f"];
const SCALES     = ["95","100","110","120"];
const OPACITY    = ["soft","normal","normal","strong"]; // чаще normal

// Что декорируем: большинство «белых»/светлых контентных блоков.
const SELECTOR = [
  ".card",                                // любые карточки (в т.ч. товары /store)
  ".bg-white",                            // белые блоки
  ".bg-light",                            // светлые блоки bootstrap
  ".list-group .list-group-item",         // айтемы списков
  ".accordion .accordion-item",           // аккордеоны
  ".alert",                               // светлые алёрты
  ".products-search-sticky"               // белая карточка поиска на /products
].join(",");

// Кого исключаем полностью (модалки НЕ исключаем):
const EXCLUDE_MATCH = [
  ".glass-panel", ".navbar", ".dropdown-menu",
  ".offcanvas", ".offcanvas-body",
  ".store-nav", ".sidebar-card.sidebar--tone",
  "[data-shape='off']", ".no-shape",
  ".modal-header", ".modal-footer"        // хедер/футер модалки оставляем чистыми
].join(",");

function shuffle(arr){
  const a = arr.slice();
  for(let i=a.length-1;i>0;i--){
    const j = Math.floor(Math.random()*(i+1));
    [a[i],a[j]]=[a[j],a[i]];
  }
  return a;
}

// ближайший предшествующий «подходящий» сосед
function prevSiblingEligible(el){
  let p = el.previousElementSibling;
  while(p){
    if(p.matches && p.matches(SELECTOR) && !p.closest(EXCLUDE_MATCH)) return p;
    p = p.previousElementSibling;
  }
  return null;
}

function decorateNode(el, ctx){
  if(el.dataset.shaped === "1") return;           // уже делали
  if(el.closest(EXCLUDE_MATCH)) return;           // внутри исключений

  el.classList.add("shape-decor");

  // — фигура: избегаем совпадения с соседом
  let shape = ctx.nextShape();
  const prev = prevSiblingEligible(el);
  if(prev && prev.dataset.shapeId === String(shape)){
    shape = ctx.nextShape(true); // сдвинем выбор
  }
  el.dataset.shapeId = String(shape);
  el.classList.add(`shape--${shape}`);

  // — позиция/размер/угол/масштаб/прозрачность (полный рандом)
  const pos = POSITIONS[Math.floor(Math.random()*POSITIONS.length)];
  const siz = SIZES[Math.floor(Math.random()*SIZES.length)];
  const rot = ROTATIONS[Math.floor(Math.random()*ROTATIONS.length)];
  const scl = SCALES[Math.floor(Math.random()*SCALES.length)];
  const op  = OPACITY[Math.floor(Math.random()*OPACITY.length)];

  el.classList.add(`shape-pos--${pos}`);
  el.classList.add(`shape-size--${siz}`);
  el.classList.add(`shape-rot--${rot}`);
  el.classList.add(`shape-scale--${scl}`);
  el.classList.add(`shape-${op}`);

  el.dataset.shaped = "1";
}

// Контекст раздачи фигур: перетасованная колода по кругу
function makeDistributor(){
  let deck = shuffle(SHAPES);
  let i = 0;
  return {
    nextShape(bump=false){
      if(bump){ i = (i+1) % deck.length; }
      const v = deck[i];
      i = (i+1) % deck.length;
      if(i===0) deck = shuffle(SHAPES);  // новый круг — перетасуем заново
      return v;
    }
  };
}

function runDecor(){
  const ctx = makeDistributor();
  const nodes = Array.from(document.querySelectorAll(SELECTOR))
    .filter(el => !el.closest(EXCLUDE_MATCH));
  nodes.forEach(el => decorateNode(el, ctx));
}

// ===== Инициализация: DOM + Turbo + MutationObserver + Bootstrap modal =====
function init(){
  runDecor();

  // Новые узлы (turbo-stream и т.п.)
  const mo = new MutationObserver(muts => {
    let need = false;
    muts.forEach(m => {
      if(m.addedNodes){
        m.addedNodes.forEach(n => {
          if(!(n instanceof HTMLElement)) return;
          if(n.matches && n.matches(SELECTOR) && !n.closest(EXCLUDE_MATCH)) need = true;
          if(!need){
            // вдруг внутри добавленного фрагмента есть карточки
            const inner = n.querySelector && n.querySelector(SELECTOR);
            if(inner && !inner.closest(EXCLUDE_MATCH)) need = true;
          }
        });
      }
    });
    if(need) runDecor();
  });
  mo.observe(document.documentElement, { childList: true, subtree: true });

  // Когда открылась модалка (детали товара на мобиле) — гарантированно декорируем
  document.addEventListener("shown.bs.modal", runDecor);
}

// Turbo
document.addEventListener("turbo:load", init);
// На старом UJS/без Turbo:
document.addEventListener("DOMContentLoaded", init);
