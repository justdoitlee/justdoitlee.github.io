<div class="copyright" style="margin-left:40%">{#
#}{% set current = date(Date.now(), "YYYY") %}{#
#}&copy; {% if theme.footer.since and theme.footer.since != current %}{{ theme.footer.since }} &mdash; {% endif %}{#
#}<span itemprop="copyrightYear">{{ current }}</span>
  <span class="with-love">
    <i class="fa fa-{{ theme.footer.icon }}"></i>
  </span>
  <span class="author" itemprop="copyrightHolder">{{ theme.footer.copyright || config.author }}</span>

  {% if theme.post_wordcount.totalcount %}
    <span class="post-meta-divider">|</span>
    <span class="post-meta-item-icon">
      <i class="fa fa-area-chart"></i>
    </span>
    {% if theme.post_wordcount.item_text %}
      <span class="post-meta-item-text">{{ __('post.totalcount') }}&#58;</span>
    {% endif %}
    <span title="{{ __('post.totalcount') }}">{#
    #}{{ totalcount(site, '0,0.0a') }}{#
  #}</span>
  {% endif %}
</div>
<div style="margin-left:30%">
{% if theme.footer.powered %}
  <div class="powered-by" >{#
  #}{{ __('footer.powered', '<a class="theme-link" target="_blank" href="https://hexo.io">Hexo</a>') }}{#
#}</div>
{% endif %}

{% if theme.footer.powered and theme.footer.theme.enable %}
  <span class="post-meta-divider">|</span>
{% endif %}

{% if theme.footer.theme.enable %}
  <div class="theme-info" >{#
  #}{{ __('footer.theme') }} &mdash; {#
  #}<a class="theme-link" target="_blank" href="https://github.com/iissnan/hexo-theme-next">{#
    #}NexT.{{ theme.scheme }}{#
  #}</a>{% if theme.footer.theme.version %} v{{ theme.version }}{% endif %}{#
#}</div>
{% endif %}
</div>
<div class="theme-info" style="margin-left:20%">
  <div class="powered-by"></div>
  <span class="post-count">博客全站共{{ totalcount(site) }}字</span>&nbsp&nbsp
  <script async src="https://dn-lbstatics.qbox.me/busuanzi/2.3/busuanzi.pure.mini.js"></script>
本站总访问量 <span id="busuanzi_value_site_pv"></span> &nbsp&nbsp
您是第<span id="busuanzi_value_site_uv"></span>个来到的小伙伴
</div>


  <div class="platelet" style="display: block; margin-left:-22%;">
    <div class="platelet-tips"></div>
    <div style="width: 250px;overflow: hidden;">
      <canvas id="live2d" width="650" height="600" class="live2d" style="width: 325px;height: 300px;"></canvas>
    </div>
    <div class="platelet-tool">
      <i class="fa fa-eye eye"></i>
      <i class="fa fa-music music"></i>
      <i class="fa fa-comment comment"></i>
      <i class="fa fa-camera camera"></i>
    </div>
  </div>
  <div id="main" class="container"></div>

<script src="https://code.jquery.com/jquery-3.2.1.js"></script>
<script src="/platelet/assets/js/live2d.js"></script>
<script src="/platelet/assets/js/platelet.js"></script>
<script src="/platelet/assets/js/renderer.js"></script>
<script type="text/javascript">
  loadlive2d("live2d", "/platelet/assets/kesshouban_v2/model.json");
</script>

{% if theme.footer.custom_text %}
  <div class="footer-custom">{#
  #}{{ theme.footer.custom_text }}{#
#}</div>
{% endif %}


