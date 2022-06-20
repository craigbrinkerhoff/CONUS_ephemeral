<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis version="3.24.0-Tisler" simplifyDrawingHints="1" simplifyAlgorithm="0" minScale="100000000" simplifyDrawingTol="1" labelsEnabled="0" simplifyLocal="1" simplifyMaxScale="1" symbologyReferenceScale="-1" hasScaleBasedVisibilityFlag="0" readOnly="0" styleCategories="AllStyleCategories" maxScale="0">
  <flags>
    <Identifiable>1</Identifiable>
    <Removable>1</Removable>
    <Searchable>1</Searchable>
    <Private>0</Private>
  </flags>
  <temporal enabled="0" startField="FDate" startExpression="" mode="0" endField="" limitMode="0" accumulate="0" durationUnit="min" fixedDuration="0" endExpression="" durationField="OBJECTID">
    <fixedRange>
      <start></start>
      <end></end>
    </fixedRange>
  </temporal>
  <renderer-v2 type="RuleRenderer" enableorderby="0" referencescale="-1" forceraster="0" symbollevels="0">
    <rules key="{ea9873f8-4c5e-4975-9332-06c8996c298c}">
      <rule symbol="0" filter="&quot;perenniality&quot; = 'ephemeral'" key="{2d8f69be-a875-4491-946d-b27502bc0929}" label="ephemeral">
        <rule symbol="1" filter="StreamOrde = 1" key="{4a1a45e3-6079-4dcd-b5c1-f35dadf1eb6b}" label="1"/>
        <rule symbol="2" filter="StreamOrde = 2" key="{9c48206a-b727-4922-93ec-484cfb4fb89e}" label="2"/>
        <rule symbol="3" filter="StreamOrde = 3" key="{32cfd7ac-6648-485d-a101-039bf0e010e2}" label="3"/>
        <rule symbol="4" filter="StreamOrde = 4" key="{51c79647-3f2f-4f69-80d0-48ef29fbff33}" label="4"/>
        <rule symbol="5" filter="StreamOrde = 5" key="{29048068-f4df-4de4-a347-03c8c54b4c5a}" label="5"/>
        <rule symbol="6" filter="StreamOrde = 6" key="{6ea0072e-7c6a-4707-890e-9a2cc796cdcf}" label="6"/>
        <rule symbol="7" filter="StreamOrde = 7" key="{fcbd8a76-d7fe-4612-81e9-d6036143e0d6}" label="7"/>
        <rule symbol="8" filter="StreamOrde = 8" key="{fcbd8a76-d7fe-4612-81e9-d6036143e0d6}" label="8"/>
        <rule symbol="9" filter="StreamOrde >=9" key="{778ff45e-24b7-42a8-a6b0-2a873f4b4580}" label="9+"/>
      </rule>
      <rule symbol="10" filter="&quot;perenniality&quot; != 'ephemeral'" key="{b017bd73-1c83-456f-8b2e-30f9064482af}" label="Non-Ephemeral">
        <rule symbol="11" filter="StreamOrde = 1" key="{668cc3d8-5ad3-474c-a726-29df2a58b5b9}" label="1"/>
        <rule symbol="12" filter="StreamOrde = 2" key="{f4a157ee-a7c6-49dd-859d-a60a5a9d6a0e}" label="2"/>
        <rule symbol="13" filter="StreamOrde = 3" key="{0beac4f8-dc47-4769-b225-988df429ab99}" label="3"/>
        <rule symbol="14" filter="StreamOrde = 4" key="{c1ba794e-ce67-45e4-ae15-a9490a40c68c}" label="4"/>
        <rule symbol="15" filter="StreamOrde = 5" key="{25c50d12-92ea-40b7-a239-50fade768985}" label="5"/>
        <rule symbol="16" filter="StreamOrde = 6" key="{440cad98-4c30-4468-afaf-ae13467ce130}" label="6"/>
        <rule symbol="17" filter="StreamOrde = 7" key="{c39783b8-b810-4eb9-b694-cb2018dd165b}" label="7"/>
        <rule symbol="18" filter="StreamOrde = 8" key="{c39783b8-b810-4eb9-b694-cb2018dd165b}" label="8"/>
        <rule symbol="19" filter="StreamOrde >= 9" key="{bccdd1a5-afb6-46a3-a7f0-6a53e445edec}" label="9+"/>
      </rule>
      <rule symbol="20" filter="ELSE" checkstate="0" key="{0c3cb36d-e6a3-4d52-bb62-3ac7426cb727}"/>
    </rules>
    <symbols>
      <symbol type="line" name="0" alpha="1" clip_to_extent="1" force_rhr="0">
        <data_defined_properties>
          <Option type="Map">
            <Option type="QString" name="name" value=""/>
            <Option name="properties"/>
            <Option type="QString" name="type" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer enabled="1" locked="0" class="SimpleLine" pass="0">
          <Option type="Map">
            <Option type="QString" name="align_dash_pattern" value="0"/>
            <Option type="QString" name="capstyle" value="square"/>
            <Option type="QString" name="customdash" value="5;2"/>
            <Option type="QString" name="customdash_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="customdash_unit" value="MM"/>
            <Option type="QString" name="dash_pattern_offset" value="0"/>
            <Option type="QString" name="dash_pattern_offset_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="dash_pattern_offset_unit" value="MM"/>
            <Option type="QString" name="draw_inside_polygon" value="0"/>
            <Option type="QString" name="joinstyle" value="bevel"/>
            <Option type="QString" name="line_color" value="243,200,90,255"/>
            <Option type="QString" name="line_style" value="solid"/>
            <Option type="QString" name="line_width" value="0.26"/>
            <Option type="QString" name="line_width_unit" value="MM"/>
            <Option type="QString" name="offset" value="0"/>
            <Option type="QString" name="offset_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="offset_unit" value="MM"/>
            <Option type="QString" name="ring_filter" value="0"/>
            <Option type="QString" name="trim_distance_end" value="0"/>
            <Option type="QString" name="trim_distance_end_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="trim_distance_end_unit" value="MM"/>
            <Option type="QString" name="trim_distance_start" value="0"/>
            <Option type="QString" name="trim_distance_start_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="trim_distance_start_unit" value="MM"/>
            <Option type="QString" name="tweak_dash_pattern_on_corners" value="0"/>
            <Option type="QString" name="use_custom_dash" value="0"/>
            <Option type="QString" name="width_map_unit_scale" value="3x:0,0,0,0,0,0"/>
          </Option>
          <prop k="align_dash_pattern" v="0"/>
          <prop k="capstyle" v="square"/>
          <prop k="customdash" v="5;2"/>
          <prop k="customdash_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="customdash_unit" v="MM"/>
          <prop k="dash_pattern_offset" v="0"/>
          <prop k="dash_pattern_offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="dash_pattern_offset_unit" v="MM"/>
          <prop k="draw_inside_polygon" v="0"/>
          <prop k="joinstyle" v="bevel"/>
          <prop k="line_color" v="243,200,90,255"/>
          <prop k="line_style" v="solid"/>
          <prop k="line_width" v="0.26"/>
          <prop k="line_width_unit" v="MM"/>
          <prop k="offset" v="0"/>
          <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="offset_unit" v="MM"/>
          <prop k="ring_filter" v="0"/>
          <prop k="trim_distance_end" v="0"/>
          <prop k="trim_distance_end_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_end_unit" v="MM"/>
          <prop k="trim_distance_start" v="0"/>
          <prop k="trim_distance_start_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_start_unit" v="MM"/>
          <prop k="tweak_dash_pattern_on_corners" v="0"/>
          <prop k="use_custom_dash" v="0"/>
          <prop k="width_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <data_defined_properties>
            <Option type="Map">
              <Option type="QString" name="name" value=""/>
              <Option name="properties"/>
              <Option type="QString" name="type" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol type="line" name="1" alpha="1" clip_to_extent="1" force_rhr="0">
        <data_defined_properties>
          <Option type="Map">
            <Option type="QString" name="name" value=""/>
            <Option name="properties"/>
            <Option type="QString" name="type" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer enabled="1" locked="0" class="SimpleLine" pass="0">
          <Option type="Map">
            <Option type="QString" name="align_dash_pattern" value="0"/>
            <Option type="QString" name="capstyle" value="square"/>
            <Option type="QString" name="customdash" value="5;2"/>
            <Option type="QString" name="customdash_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="customdash_unit" value="MM"/>
            <Option type="QString" name="dash_pattern_offset" value="0"/>
            <Option type="QString" name="dash_pattern_offset_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="dash_pattern_offset_unit" value="MM"/>
            <Option type="QString" name="draw_inside_polygon" value="0"/>
            <Option type="QString" name="joinstyle" value="bevel"/>
            <Option type="QString" name="line_color" value="243,200,90,255"/>
            <Option type="QString" name="line_style" value="solid"/>
            <Option type="QString" name="line_width" value="0.1"/>
            <Option type="QString" name="line_width_unit" value="MM"/>
            <Option type="QString" name="offset" value="0"/>
            <Option type="QString" name="offset_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="offset_unit" value="MM"/>
            <Option type="QString" name="ring_filter" value="0"/>
            <Option type="QString" name="trim_distance_end" value="0"/>
            <Option type="QString" name="trim_distance_end_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="trim_distance_end_unit" value="MM"/>
            <Option type="QString" name="trim_distance_start" value="0"/>
            <Option type="QString" name="trim_distance_start_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="trim_distance_start_unit" value="MM"/>
            <Option type="QString" name="tweak_dash_pattern_on_corners" value="0"/>
            <Option type="QString" name="use_custom_dash" value="0"/>
            <Option type="QString" name="width_map_unit_scale" value="3x:0,0,0,0,0,0"/>
          </Option>
          <prop k="align_dash_pattern" v="0"/>
          <prop k="capstyle" v="square"/>
          <prop k="customdash" v="5;2"/>
          <prop k="customdash_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="customdash_unit" v="MM"/>
          <prop k="dash_pattern_offset" v="0"/>
          <prop k="dash_pattern_offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="dash_pattern_offset_unit" v="MM"/>
          <prop k="draw_inside_polygon" v="0"/>
          <prop k="joinstyle" v="bevel"/>
          <prop k="line_color" v="243,200,90,255"/>
          <prop k="line_style" v="solid"/>
          <prop k="line_width" v="0.1"/>
          <prop k="line_width_unit" v="MM"/>
          <prop k="offset" v="0"/>
          <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="offset_unit" v="MM"/>
          <prop k="ring_filter" v="0"/>
          <prop k="trim_distance_end" v="0"/>
          <prop k="trim_distance_end_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_end_unit" v="MM"/>
          <prop k="trim_distance_start" v="0"/>
          <prop k="trim_distance_start_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_start_unit" v="MM"/>
          <prop k="tweak_dash_pattern_on_corners" v="0"/>
          <prop k="use_custom_dash" v="0"/>
          <prop k="width_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <data_defined_properties>
            <Option type="Map">
              <Option type="QString" name="name" value=""/>
              <Option name="properties"/>
              <Option type="QString" name="type" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol type="line" name="10" alpha="1" clip_to_extent="1" force_rhr="0">
        <data_defined_properties>
          <Option type="Map">
            <Option type="QString" name="name" value=""/>
            <Option name="properties"/>
            <Option type="QString" name="type" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer enabled="1" locked="0" class="SimpleLine" pass="0">
          <Option type="Map">
            <Option type="QString" name="align_dash_pattern" value="0"/>
            <Option type="QString" name="capstyle" value="square"/>
            <Option type="QString" name="customdash" value="5;2"/>
            <Option type="QString" name="customdash_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="customdash_unit" value="MM"/>
            <Option type="QString" name="dash_pattern_offset" value="0"/>
            <Option type="QString" name="dash_pattern_offset_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="dash_pattern_offset_unit" value="MM"/>
            <Option type="QString" name="draw_inside_polygon" value="0"/>
            <Option type="QString" name="joinstyle" value="bevel"/>
            <Option type="QString" name="line_color" value="15,21,183,255"/>
            <Option type="QString" name="line_style" value="solid"/>
            <Option type="QString" name="line_width" value="0.26"/>
            <Option type="QString" name="line_width_unit" value="MM"/>
            <Option type="QString" name="offset" value="0"/>
            <Option type="QString" name="offset_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="offset_unit" value="MM"/>
            <Option type="QString" name="ring_filter" value="0"/>
            <Option type="QString" name="trim_distance_end" value="0"/>
            <Option type="QString" name="trim_distance_end_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="trim_distance_end_unit" value="MM"/>
            <Option type="QString" name="trim_distance_start" value="0"/>
            <Option type="QString" name="trim_distance_start_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="trim_distance_start_unit" value="MM"/>
            <Option type="QString" name="tweak_dash_pattern_on_corners" value="0"/>
            <Option type="QString" name="use_custom_dash" value="0"/>
            <Option type="QString" name="width_map_unit_scale" value="3x:0,0,0,0,0,0"/>
          </Option>
          <prop k="align_dash_pattern" v="0"/>
          <prop k="capstyle" v="square"/>
          <prop k="customdash" v="5;2"/>
          <prop k="customdash_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="customdash_unit" v="MM"/>
          <prop k="dash_pattern_offset" v="0"/>
          <prop k="dash_pattern_offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="dash_pattern_offset_unit" v="MM"/>
          <prop k="draw_inside_polygon" v="0"/>
          <prop k="joinstyle" v="bevel"/>
          <prop k="line_color" v="15,21,183,255"/>
          <prop k="line_style" v="solid"/>
          <prop k="line_width" v="0.26"/>
          <prop k="line_width_unit" v="MM"/>
          <prop k="offset" v="0"/>
          <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="offset_unit" v="MM"/>
          <prop k="ring_filter" v="0"/>
          <prop k="trim_distance_end" v="0"/>
          <prop k="trim_distance_end_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_end_unit" v="MM"/>
          <prop k="trim_distance_start" v="0"/>
          <prop k="trim_distance_start_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_start_unit" v="MM"/>
          <prop k="tweak_dash_pattern_on_corners" v="0"/>
          <prop k="use_custom_dash" v="0"/>
          <prop k="width_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <data_defined_properties>
            <Option type="Map">
              <Option type="QString" name="name" value=""/>
              <Option name="properties"/>
              <Option type="QString" name="type" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol type="line" name="11" alpha="1" clip_to_extent="1" force_rhr="0">
        <data_defined_properties>
          <Option type="Map">
            <Option type="QString" name="name" value=""/>
            <Option name="properties"/>
            <Option type="QString" name="type" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer enabled="1" locked="0" class="SimpleLine" pass="0">
          <Option type="Map">
            <Option type="QString" name="align_dash_pattern" value="0"/>
            <Option type="QString" name="capstyle" value="square"/>
            <Option type="QString" name="customdash" value="5;2"/>
            <Option type="QString" name="customdash_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="customdash_unit" value="MM"/>
            <Option type="QString" name="dash_pattern_offset" value="0"/>
            <Option type="QString" name="dash_pattern_offset_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="dash_pattern_offset_unit" value="MM"/>
            <Option type="QString" name="draw_inside_polygon" value="0"/>
            <Option type="QString" name="joinstyle" value="bevel"/>
            <Option type="QString" name="line_color" value="15,21,183,255"/>
            <Option type="QString" name="line_style" value="solid"/>
            <Option type="QString" name="line_width" value="0.1"/>
            <Option type="QString" name="line_width_unit" value="MM"/>
            <Option type="QString" name="offset" value="0"/>
            <Option type="QString" name="offset_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="offset_unit" value="MM"/>
            <Option type="QString" name="ring_filter" value="0"/>
            <Option type="QString" name="trim_distance_end" value="0"/>
            <Option type="QString" name="trim_distance_end_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="trim_distance_end_unit" value="MM"/>
            <Option type="QString" name="trim_distance_start" value="0"/>
            <Option type="QString" name="trim_distance_start_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="trim_distance_start_unit" value="MM"/>
            <Option type="QString" name="tweak_dash_pattern_on_corners" value="0"/>
            <Option type="QString" name="use_custom_dash" value="0"/>
            <Option type="QString" name="width_map_unit_scale" value="3x:0,0,0,0,0,0"/>
          </Option>
          <prop k="align_dash_pattern" v="0"/>
          <prop k="capstyle" v="square"/>
          <prop k="customdash" v="5;2"/>
          <prop k="customdash_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="customdash_unit" v="MM"/>
          <prop k="dash_pattern_offset" v="0"/>
          <prop k="dash_pattern_offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="dash_pattern_offset_unit" v="MM"/>
          <prop k="draw_inside_polygon" v="0"/>
          <prop k="joinstyle" v="bevel"/>
          <prop k="line_color" v="15,21,183,255"/>
          <prop k="line_style" v="solid"/>
          <prop k="line_width" v="0.1"/>
          <prop k="line_width_unit" v="MM"/>
          <prop k="offset" v="0"/>
          <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="offset_unit" v="MM"/>
          <prop k="ring_filter" v="0"/>
          <prop k="trim_distance_end" v="0"/>
          <prop k="trim_distance_end_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_end_unit" v="MM"/>
          <prop k="trim_distance_start" v="0"/>
          <prop k="trim_distance_start_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_start_unit" v="MM"/>
          <prop k="tweak_dash_pattern_on_corners" v="0"/>
          <prop k="use_custom_dash" v="0"/>
          <prop k="width_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <data_defined_properties>
            <Option type="Map">
              <Option type="QString" name="name" value=""/>
              <Option name="properties"/>
              <Option type="QString" name="type" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol type="line" name="12" alpha="1" clip_to_extent="1" force_rhr="0">
        <data_defined_properties>
          <Option type="Map">
            <Option type="QString" name="name" value=""/>
            <Option name="properties"/>
            <Option type="QString" name="type" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer enabled="1" locked="0" class="SimpleLine" pass="0">
          <Option type="Map">
            <Option type="QString" name="align_dash_pattern" value="0"/>
            <Option type="QString" name="capstyle" value="square"/>
            <Option type="QString" name="customdash" value="5;2"/>
            <Option type="QString" name="customdash_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="customdash_unit" value="MM"/>
            <Option type="QString" name="dash_pattern_offset" value="0"/>
            <Option type="QString" name="dash_pattern_offset_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="dash_pattern_offset_unit" value="MM"/>
            <Option type="QString" name="draw_inside_polygon" value="0"/>
            <Option type="QString" name="joinstyle" value="bevel"/>
            <Option type="QString" name="line_color" value="15,21,183,255"/>
            <Option type="QString" name="line_style" value="solid"/>
            <Option type="QString" name="line_width" value="0.37143"/>
            <Option type="QString" name="line_width_unit" value="MM"/>
            <Option type="QString" name="offset" value="0"/>
            <Option type="QString" name="offset_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="offset_unit" value="MM"/>
            <Option type="QString" name="ring_filter" value="0"/>
            <Option type="QString" name="trim_distance_end" value="0"/>
            <Option type="QString" name="trim_distance_end_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="trim_distance_end_unit" value="MM"/>
            <Option type="QString" name="trim_distance_start" value="0"/>
            <Option type="QString" name="trim_distance_start_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="trim_distance_start_unit" value="MM"/>
            <Option type="QString" name="tweak_dash_pattern_on_corners" value="0"/>
            <Option type="QString" name="use_custom_dash" value="0"/>
            <Option type="QString" name="width_map_unit_scale" value="3x:0,0,0,0,0,0"/>
          </Option>
          <prop k="align_dash_pattern" v="0"/>
          <prop k="capstyle" v="square"/>
          <prop k="customdash" v="5;2"/>
          <prop k="customdash_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="customdash_unit" v="MM"/>
          <prop k="dash_pattern_offset" v="0"/>
          <prop k="dash_pattern_offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="dash_pattern_offset_unit" v="MM"/>
          <prop k="draw_inside_polygon" v="0"/>
          <prop k="joinstyle" v="bevel"/>
          <prop k="line_color" v="15,21,183,255"/>
          <prop k="line_style" v="solid"/>
          <prop k="line_width" v="0.37143"/>
          <prop k="line_width_unit" v="MM"/>
          <prop k="offset" v="0"/>
          <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="offset_unit" v="MM"/>
          <prop k="ring_filter" v="0"/>
          <prop k="trim_distance_end" v="0"/>
          <prop k="trim_distance_end_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_end_unit" v="MM"/>
          <prop k="trim_distance_start" v="0"/>
          <prop k="trim_distance_start_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_start_unit" v="MM"/>
          <prop k="tweak_dash_pattern_on_corners" v="0"/>
          <prop k="use_custom_dash" v="0"/>
          <prop k="width_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <data_defined_properties>
            <Option type="Map">
              <Option type="QString" name="name" value=""/>
              <Option name="properties"/>
              <Option type="QString" name="type" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol type="line" name="13" alpha="1" clip_to_extent="1" force_rhr="0">
        <data_defined_properties>
          <Option type="Map">
            <Option type="QString" name="name" value=""/>
            <Option name="properties"/>
            <Option type="QString" name="type" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer enabled="1" locked="0" class="SimpleLine" pass="0">
          <Option type="Map">
            <Option type="QString" name="align_dash_pattern" value="0"/>
            <Option type="QString" name="capstyle" value="square"/>
            <Option type="QString" name="customdash" value="5;2"/>
            <Option type="QString" name="customdash_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="customdash_unit" value="MM"/>
            <Option type="QString" name="dash_pattern_offset" value="0"/>
            <Option type="QString" name="dash_pattern_offset_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="dash_pattern_offset_unit" value="MM"/>
            <Option type="QString" name="draw_inside_polygon" value="0"/>
            <Option type="QString" name="joinstyle" value="bevel"/>
            <Option type="QString" name="line_color" value="15,21,183,255"/>
            <Option type="QString" name="line_style" value="solid"/>
            <Option type="QString" name="line_width" value="0.64286"/>
            <Option type="QString" name="line_width_unit" value="MM"/>
            <Option type="QString" name="offset" value="0"/>
            <Option type="QString" name="offset_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="offset_unit" value="MM"/>
            <Option type="QString" name="ring_filter" value="0"/>
            <Option type="QString" name="trim_distance_end" value="0"/>
            <Option type="QString" name="trim_distance_end_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="trim_distance_end_unit" value="MM"/>
            <Option type="QString" name="trim_distance_start" value="0"/>
            <Option type="QString" name="trim_distance_start_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="trim_distance_start_unit" value="MM"/>
            <Option type="QString" name="tweak_dash_pattern_on_corners" value="0"/>
            <Option type="QString" name="use_custom_dash" value="0"/>
            <Option type="QString" name="width_map_unit_scale" value="3x:0,0,0,0,0,0"/>
          </Option>
          <prop k="align_dash_pattern" v="0"/>
          <prop k="capstyle" v="square"/>
          <prop k="customdash" v="5;2"/>
          <prop k="customdash_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="customdash_unit" v="MM"/>
          <prop k="dash_pattern_offset" v="0"/>
          <prop k="dash_pattern_offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="dash_pattern_offset_unit" v="MM"/>
          <prop k="draw_inside_polygon" v="0"/>
          <prop k="joinstyle" v="bevel"/>
          <prop k="line_color" v="15,21,183,255"/>
          <prop k="line_style" v="solid"/>
          <prop k="line_width" v="0.64286"/>
          <prop k="line_width_unit" v="MM"/>
          <prop k="offset" v="0"/>
          <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="offset_unit" v="MM"/>
          <prop k="ring_filter" v="0"/>
          <prop k="trim_distance_end" v="0"/>
          <prop k="trim_distance_end_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_end_unit" v="MM"/>
          <prop k="trim_distance_start" v="0"/>
          <prop k="trim_distance_start_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_start_unit" v="MM"/>
          <prop k="tweak_dash_pattern_on_corners" v="0"/>
          <prop k="use_custom_dash" v="0"/>
          <prop k="width_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <data_defined_properties>
            <Option type="Map">
              <Option type="QString" name="name" value=""/>
              <Option name="properties"/>
              <Option type="QString" name="type" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol type="line" name="14" alpha="1" clip_to_extent="1" force_rhr="0">
        <data_defined_properties>
          <Option type="Map">
            <Option type="QString" name="name" value=""/>
            <Option name="properties"/>
            <Option type="QString" name="type" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer enabled="1" locked="0" class="SimpleLine" pass="0">
          <Option type="Map">
            <Option type="QString" name="align_dash_pattern" value="0"/>
            <Option type="QString" name="capstyle" value="square"/>
            <Option type="QString" name="customdash" value="5;2"/>
            <Option type="QString" name="customdash_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="customdash_unit" value="MM"/>
            <Option type="QString" name="dash_pattern_offset" value="0"/>
            <Option type="QString" name="dash_pattern_offset_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="dash_pattern_offset_unit" value="MM"/>
            <Option type="QString" name="draw_inside_polygon" value="0"/>
            <Option type="QString" name="joinstyle" value="bevel"/>
            <Option type="QString" name="line_color" value="15,21,183,255"/>
            <Option type="QString" name="line_style" value="solid"/>
            <Option type="QString" name="line_width" value="0.91429"/>
            <Option type="QString" name="line_width_unit" value="MM"/>
            <Option type="QString" name="offset" value="0"/>
            <Option type="QString" name="offset_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="offset_unit" value="MM"/>
            <Option type="QString" name="ring_filter" value="0"/>
            <Option type="QString" name="trim_distance_end" value="0"/>
            <Option type="QString" name="trim_distance_end_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="trim_distance_end_unit" value="MM"/>
            <Option type="QString" name="trim_distance_start" value="0"/>
            <Option type="QString" name="trim_distance_start_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="trim_distance_start_unit" value="MM"/>
            <Option type="QString" name="tweak_dash_pattern_on_corners" value="0"/>
            <Option type="QString" name="use_custom_dash" value="0"/>
            <Option type="QString" name="width_map_unit_scale" value="3x:0,0,0,0,0,0"/>
          </Option>
          <prop k="align_dash_pattern" v="0"/>
          <prop k="capstyle" v="square"/>
          <prop k="customdash" v="5;2"/>
          <prop k="customdash_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="customdash_unit" v="MM"/>
          <prop k="dash_pattern_offset" v="0"/>
          <prop k="dash_pattern_offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="dash_pattern_offset_unit" v="MM"/>
          <prop k="draw_inside_polygon" v="0"/>
          <prop k="joinstyle" v="bevel"/>
          <prop k="line_color" v="15,21,183,255"/>
          <prop k="line_style" v="solid"/>
          <prop k="line_width" v="0.91429"/>
          <prop k="line_width_unit" v="MM"/>
          <prop k="offset" v="0"/>
          <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="offset_unit" v="MM"/>
          <prop k="ring_filter" v="0"/>
          <prop k="trim_distance_end" v="0"/>
          <prop k="trim_distance_end_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_end_unit" v="MM"/>
          <prop k="trim_distance_start" v="0"/>
          <prop k="trim_distance_start_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_start_unit" v="MM"/>
          <prop k="tweak_dash_pattern_on_corners" v="0"/>
          <prop k="use_custom_dash" v="0"/>
          <prop k="width_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <data_defined_properties>
            <Option type="Map">
              <Option type="QString" name="name" value=""/>
              <Option name="properties"/>
              <Option type="QString" name="type" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol type="line" name="15" alpha="1" clip_to_extent="1" force_rhr="0">
        <data_defined_properties>
          <Option type="Map">
            <Option type="QString" name="name" value=""/>
            <Option name="properties"/>
            <Option type="QString" name="type" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer enabled="1" locked="0" class="SimpleLine" pass="0">
          <Option type="Map">
            <Option type="QString" name="align_dash_pattern" value="0"/>
            <Option type="QString" name="capstyle" value="square"/>
            <Option type="QString" name="customdash" value="5;2"/>
            <Option type="QString" name="customdash_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="customdash_unit" value="MM"/>
            <Option type="QString" name="dash_pattern_offset" value="0"/>
            <Option type="QString" name="dash_pattern_offset_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="dash_pattern_offset_unit" value="MM"/>
            <Option type="QString" name="draw_inside_polygon" value="0"/>
            <Option type="QString" name="joinstyle" value="bevel"/>
            <Option type="QString" name="line_color" value="15,21,183,255"/>
            <Option type="QString" name="line_style" value="solid"/>
            <Option type="QString" name="line_width" value="1.18571"/>
            <Option type="QString" name="line_width_unit" value="MM"/>
            <Option type="QString" name="offset" value="0"/>
            <Option type="QString" name="offset_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="offset_unit" value="MM"/>
            <Option type="QString" name="ring_filter" value="0"/>
            <Option type="QString" name="trim_distance_end" value="0"/>
            <Option type="QString" name="trim_distance_end_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="trim_distance_end_unit" value="MM"/>
            <Option type="QString" name="trim_distance_start" value="0"/>
            <Option type="QString" name="trim_distance_start_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="trim_distance_start_unit" value="MM"/>
            <Option type="QString" name="tweak_dash_pattern_on_corners" value="0"/>
            <Option type="QString" name="use_custom_dash" value="0"/>
            <Option type="QString" name="width_map_unit_scale" value="3x:0,0,0,0,0,0"/>
          </Option>
          <prop k="align_dash_pattern" v="0"/>
          <prop k="capstyle" v="square"/>
          <prop k="customdash" v="5;2"/>
          <prop k="customdash_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="customdash_unit" v="MM"/>
          <prop k="dash_pattern_offset" v="0"/>
          <prop k="dash_pattern_offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="dash_pattern_offset_unit" v="MM"/>
          <prop k="draw_inside_polygon" v="0"/>
          <prop k="joinstyle" v="bevel"/>
          <prop k="line_color" v="15,21,183,255"/>
          <prop k="line_style" v="solid"/>
          <prop k="line_width" v="1.18571"/>
          <prop k="line_width_unit" v="MM"/>
          <prop k="offset" v="0"/>
          <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="offset_unit" v="MM"/>
          <prop k="ring_filter" v="0"/>
          <prop k="trim_distance_end" v="0"/>
          <prop k="trim_distance_end_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_end_unit" v="MM"/>
          <prop k="trim_distance_start" v="0"/>
          <prop k="trim_distance_start_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_start_unit" v="MM"/>
          <prop k="tweak_dash_pattern_on_corners" v="0"/>
          <prop k="use_custom_dash" v="0"/>
          <prop k="width_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <data_defined_properties>
            <Option type="Map">
              <Option type="QString" name="name" value=""/>
              <Option name="properties"/>
              <Option type="QString" name="type" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol type="line" name="16" alpha="1" clip_to_extent="1" force_rhr="0">
        <data_defined_properties>
          <Option type="Map">
            <Option type="QString" name="name" value=""/>
            <Option name="properties"/>
            <Option type="QString" name="type" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer enabled="1" locked="0" class="SimpleLine" pass="0">
          <Option type="Map">
            <Option type="QString" name="align_dash_pattern" value="0"/>
            <Option type="QString" name="capstyle" value="square"/>
            <Option type="QString" name="customdash" value="5;2"/>
            <Option type="QString" name="customdash_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="customdash_unit" value="MM"/>
            <Option type="QString" name="dash_pattern_offset" value="0"/>
            <Option type="QString" name="dash_pattern_offset_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="dash_pattern_offset_unit" value="MM"/>
            <Option type="QString" name="draw_inside_polygon" value="0"/>
            <Option type="QString" name="joinstyle" value="bevel"/>
            <Option type="QString" name="line_color" value="15,21,183,255"/>
            <Option type="QString" name="line_style" value="solid"/>
            <Option type="QString" name="line_width" value="1.45714"/>
            <Option type="QString" name="line_width_unit" value="MM"/>
            <Option type="QString" name="offset" value="0"/>
            <Option type="QString" name="offset_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="offset_unit" value="MM"/>
            <Option type="QString" name="ring_filter" value="0"/>
            <Option type="QString" name="trim_distance_end" value="0"/>
            <Option type="QString" name="trim_distance_end_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="trim_distance_end_unit" value="MM"/>
            <Option type="QString" name="trim_distance_start" value="0"/>
            <Option type="QString" name="trim_distance_start_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="trim_distance_start_unit" value="MM"/>
            <Option type="QString" name="tweak_dash_pattern_on_corners" value="0"/>
            <Option type="QString" name="use_custom_dash" value="0"/>
            <Option type="QString" name="width_map_unit_scale" value="3x:0,0,0,0,0,0"/>
          </Option>
          <prop k="align_dash_pattern" v="0"/>
          <prop k="capstyle" v="square"/>
          <prop k="customdash" v="5;2"/>
          <prop k="customdash_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="customdash_unit" v="MM"/>
          <prop k="dash_pattern_offset" v="0"/>
          <prop k="dash_pattern_offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="dash_pattern_offset_unit" v="MM"/>
          <prop k="draw_inside_polygon" v="0"/>
          <prop k="joinstyle" v="bevel"/>
          <prop k="line_color" v="15,21,183,255"/>
          <prop k="line_style" v="solid"/>
          <prop k="line_width" v="1.45714"/>
          <prop k="line_width_unit" v="MM"/>
          <prop k="offset" v="0"/>
          <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="offset_unit" v="MM"/>
          <prop k="ring_filter" v="0"/>
          <prop k="trim_distance_end" v="0"/>
          <prop k="trim_distance_end_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_end_unit" v="MM"/>
          <prop k="trim_distance_start" v="0"/>
          <prop k="trim_distance_start_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_start_unit" v="MM"/>
          <prop k="tweak_dash_pattern_on_corners" v="0"/>
          <prop k="use_custom_dash" v="0"/>
          <prop k="width_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <data_defined_properties>
            <Option type="Map">
              <Option type="QString" name="name" value=""/>
              <Option name="properties"/>
              <Option type="QString" name="type" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol type="line" name="17" alpha="1" clip_to_extent="1" force_rhr="0">
        <data_defined_properties>
          <Option type="Map">
            <Option type="QString" name="name" value=""/>
            <Option name="properties"/>
            <Option type="QString" name="type" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer enabled="1" locked="0" class="SimpleLine" pass="0">
          <Option type="Map">
            <Option type="QString" name="align_dash_pattern" value="0"/>
            <Option type="QString" name="capstyle" value="square"/>
            <Option type="QString" name="customdash" value="5;2"/>
            <Option type="QString" name="customdash_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="customdash_unit" value="MM"/>
            <Option type="QString" name="dash_pattern_offset" value="0"/>
            <Option type="QString" name="dash_pattern_offset_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="dash_pattern_offset_unit" value="MM"/>
            <Option type="QString" name="draw_inside_polygon" value="0"/>
            <Option type="QString" name="joinstyle" value="bevel"/>
            <Option type="QString" name="line_color" value="15,21,183,255"/>
            <Option type="QString" name="line_style" value="solid"/>
            <Option type="QString" name="line_width" value="1.72857"/>
            <Option type="QString" name="line_width_unit" value="MM"/>
            <Option type="QString" name="offset" value="0"/>
            <Option type="QString" name="offset_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="offset_unit" value="MM"/>
            <Option type="QString" name="ring_filter" value="0"/>
            <Option type="QString" name="trim_distance_end" value="0"/>
            <Option type="QString" name="trim_distance_end_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="trim_distance_end_unit" value="MM"/>
            <Option type="QString" name="trim_distance_start" value="0"/>
            <Option type="QString" name="trim_distance_start_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="trim_distance_start_unit" value="MM"/>
            <Option type="QString" name="tweak_dash_pattern_on_corners" value="0"/>
            <Option type="QString" name="use_custom_dash" value="0"/>
            <Option type="QString" name="width_map_unit_scale" value="3x:0,0,0,0,0,0"/>
          </Option>
          <prop k="align_dash_pattern" v="0"/>
          <prop k="capstyle" v="square"/>
          <prop k="customdash" v="5;2"/>
          <prop k="customdash_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="customdash_unit" v="MM"/>
          <prop k="dash_pattern_offset" v="0"/>
          <prop k="dash_pattern_offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="dash_pattern_offset_unit" v="MM"/>
          <prop k="draw_inside_polygon" v="0"/>
          <prop k="joinstyle" v="bevel"/>
          <prop k="line_color" v="15,21,183,255"/>
          <prop k="line_style" v="solid"/>
          <prop k="line_width" v="1.72857"/>
          <prop k="line_width_unit" v="MM"/>
          <prop k="offset" v="0"/>
          <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="offset_unit" v="MM"/>
          <prop k="ring_filter" v="0"/>
          <prop k="trim_distance_end" v="0"/>
          <prop k="trim_distance_end_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_end_unit" v="MM"/>
          <prop k="trim_distance_start" v="0"/>
          <prop k="trim_distance_start_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_start_unit" v="MM"/>
          <prop k="tweak_dash_pattern_on_corners" v="0"/>
          <prop k="use_custom_dash" v="0"/>
          <prop k="width_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <data_defined_properties>
            <Option type="Map">
              <Option type="QString" name="name" value=""/>
              <Option name="properties"/>
              <Option type="QString" name="type" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol type="line" name="18" alpha="1" clip_to_extent="1" force_rhr="0">
        <data_defined_properties>
          <Option type="Map">
            <Option type="QString" name="name" value=""/>
            <Option name="properties"/>
            <Option type="QString" name="type" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer enabled="1" locked="0" class="SimpleLine" pass="0">
          <Option type="Map">
            <Option type="QString" name="align_dash_pattern" value="0"/>
            <Option type="QString" name="capstyle" value="square"/>
            <Option type="QString" name="customdash" value="5;2"/>
            <Option type="QString" name="customdash_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="customdash_unit" value="MM"/>
            <Option type="QString" name="dash_pattern_offset" value="0"/>
            <Option type="QString" name="dash_pattern_offset_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="dash_pattern_offset_unit" value="MM"/>
            <Option type="QString" name="draw_inside_polygon" value="0"/>
            <Option type="QString" name="joinstyle" value="bevel"/>
            <Option type="QString" name="line_color" value="15,21,183,255"/>
            <Option type="QString" name="line_style" value="solid"/>
            <Option type="QString" name="line_width" value="1.72857"/>
            <Option type="QString" name="line_width_unit" value="MM"/>
            <Option type="QString" name="offset" value="0"/>
            <Option type="QString" name="offset_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="offset_unit" value="MM"/>
            <Option type="QString" name="ring_filter" value="0"/>
            <Option type="QString" name="trim_distance_end" value="0"/>
            <Option type="QString" name="trim_distance_end_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="trim_distance_end_unit" value="MM"/>
            <Option type="QString" name="trim_distance_start" value="0"/>
            <Option type="QString" name="trim_distance_start_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="trim_distance_start_unit" value="MM"/>
            <Option type="QString" name="tweak_dash_pattern_on_corners" value="0"/>
            <Option type="QString" name="use_custom_dash" value="0"/>
            <Option type="QString" name="width_map_unit_scale" value="3x:0,0,0,0,0,0"/>
          </Option>
          <prop k="align_dash_pattern" v="0"/>
          <prop k="capstyle" v="square"/>
          <prop k="customdash" v="5;2"/>
          <prop k="customdash_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="customdash_unit" v="MM"/>
          <prop k="dash_pattern_offset" v="0"/>
          <prop k="dash_pattern_offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="dash_pattern_offset_unit" v="MM"/>
          <prop k="draw_inside_polygon" v="0"/>
          <prop k="joinstyle" v="bevel"/>
          <prop k="line_color" v="15,21,183,255"/>
          <prop k="line_style" v="solid"/>
          <prop k="line_width" v="1.72857"/>
          <prop k="line_width_unit" v="MM"/>
          <prop k="offset" v="0"/>
          <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="offset_unit" v="MM"/>
          <prop k="ring_filter" v="0"/>
          <prop k="trim_distance_end" v="0"/>
          <prop k="trim_distance_end_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_end_unit" v="MM"/>
          <prop k="trim_distance_start" v="0"/>
          <prop k="trim_distance_start_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_start_unit" v="MM"/>
          <prop k="tweak_dash_pattern_on_corners" v="0"/>
          <prop k="use_custom_dash" v="0"/>
          <prop k="width_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <data_defined_properties>
            <Option type="Map">
              <Option type="QString" name="name" value=""/>
              <Option name="properties"/>
              <Option type="QString" name="type" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol type="line" name="19" alpha="1" clip_to_extent="1" force_rhr="0">
        <data_defined_properties>
          <Option type="Map">
            <Option type="QString" name="name" value=""/>
            <Option name="properties"/>
            <Option type="QString" name="type" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer enabled="1" locked="0" class="SimpleLine" pass="0">
          <Option type="Map">
            <Option type="QString" name="align_dash_pattern" value="0"/>
            <Option type="QString" name="capstyle" value="square"/>
            <Option type="QString" name="customdash" value="5;2"/>
            <Option type="QString" name="customdash_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="customdash_unit" value="MM"/>
            <Option type="QString" name="dash_pattern_offset" value="0"/>
            <Option type="QString" name="dash_pattern_offset_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="dash_pattern_offset_unit" value="MM"/>
            <Option type="QString" name="draw_inside_polygon" value="0"/>
            <Option type="QString" name="joinstyle" value="bevel"/>
            <Option type="QString" name="line_color" value="15,21,183,255"/>
            <Option type="QString" name="line_style" value="solid"/>
            <Option type="QString" name="line_width" value="1.72857"/>
            <Option type="QString" name="line_width_unit" value="MM"/>
            <Option type="QString" name="offset" value="0"/>
            <Option type="QString" name="offset_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="offset_unit" value="MM"/>
            <Option type="QString" name="ring_filter" value="0"/>
            <Option type="QString" name="trim_distance_end" value="0"/>
            <Option type="QString" name="trim_distance_end_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="trim_distance_end_unit" value="MM"/>
            <Option type="QString" name="trim_distance_start" value="0"/>
            <Option type="QString" name="trim_distance_start_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="trim_distance_start_unit" value="MM"/>
            <Option type="QString" name="tweak_dash_pattern_on_corners" value="0"/>
            <Option type="QString" name="use_custom_dash" value="0"/>
            <Option type="QString" name="width_map_unit_scale" value="3x:0,0,0,0,0,0"/>
          </Option>
          <prop k="align_dash_pattern" v="0"/>
          <prop k="capstyle" v="square"/>
          <prop k="customdash" v="5;2"/>
          <prop k="customdash_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="customdash_unit" v="MM"/>
          <prop k="dash_pattern_offset" v="0"/>
          <prop k="dash_pattern_offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="dash_pattern_offset_unit" v="MM"/>
          <prop k="draw_inside_polygon" v="0"/>
          <prop k="joinstyle" v="bevel"/>
          <prop k="line_color" v="15,21,183,255"/>
          <prop k="line_style" v="solid"/>
          <prop k="line_width" v="1.72857"/>
          <prop k="line_width_unit" v="MM"/>
          <prop k="offset" v="0"/>
          <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="offset_unit" v="MM"/>
          <prop k="ring_filter" v="0"/>
          <prop k="trim_distance_end" v="0"/>
          <prop k="trim_distance_end_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_end_unit" v="MM"/>
          <prop k="trim_distance_start" v="0"/>
          <prop k="trim_distance_start_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_start_unit" v="MM"/>
          <prop k="tweak_dash_pattern_on_corners" v="0"/>
          <prop k="use_custom_dash" v="0"/>
          <prop k="width_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <data_defined_properties>
            <Option type="Map">
              <Option type="QString" name="name" value=""/>
              <Option name="properties"/>
              <Option type="QString" name="type" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol type="line" name="2" alpha="1" clip_to_extent="1" force_rhr="0">
        <data_defined_properties>
          <Option type="Map">
            <Option type="QString" name="name" value=""/>
            <Option name="properties"/>
            <Option type="QString" name="type" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer enabled="1" locked="0" class="SimpleLine" pass="0">
          <Option type="Map">
            <Option type="QString" name="align_dash_pattern" value="0"/>
            <Option type="QString" name="capstyle" value="square"/>
            <Option type="QString" name="customdash" value="5;2"/>
            <Option type="QString" name="customdash_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="customdash_unit" value="MM"/>
            <Option type="QString" name="dash_pattern_offset" value="0"/>
            <Option type="QString" name="dash_pattern_offset_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="dash_pattern_offset_unit" value="MM"/>
            <Option type="QString" name="draw_inside_polygon" value="0"/>
            <Option type="QString" name="joinstyle" value="bevel"/>
            <Option type="QString" name="line_color" value="243,200,90,255"/>
            <Option type="QString" name="line_style" value="solid"/>
            <Option type="QString" name="line_width" value="0.3375"/>
            <Option type="QString" name="line_width_unit" value="MM"/>
            <Option type="QString" name="offset" value="0"/>
            <Option type="QString" name="offset_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="offset_unit" value="MM"/>
            <Option type="QString" name="ring_filter" value="0"/>
            <Option type="QString" name="trim_distance_end" value="0"/>
            <Option type="QString" name="trim_distance_end_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="trim_distance_end_unit" value="MM"/>
            <Option type="QString" name="trim_distance_start" value="0"/>
            <Option type="QString" name="trim_distance_start_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="trim_distance_start_unit" value="MM"/>
            <Option type="QString" name="tweak_dash_pattern_on_corners" value="0"/>
            <Option type="QString" name="use_custom_dash" value="0"/>
            <Option type="QString" name="width_map_unit_scale" value="3x:0,0,0,0,0,0"/>
          </Option>
          <prop k="align_dash_pattern" v="0"/>
          <prop k="capstyle" v="square"/>
          <prop k="customdash" v="5;2"/>
          <prop k="customdash_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="customdash_unit" v="MM"/>
          <prop k="dash_pattern_offset" v="0"/>
          <prop k="dash_pattern_offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="dash_pattern_offset_unit" v="MM"/>
          <prop k="draw_inside_polygon" v="0"/>
          <prop k="joinstyle" v="bevel"/>
          <prop k="line_color" v="243,200,90,255"/>
          <prop k="line_style" v="solid"/>
          <prop k="line_width" v="0.3375"/>
          <prop k="line_width_unit" v="MM"/>
          <prop k="offset" v="0"/>
          <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="offset_unit" v="MM"/>
          <prop k="ring_filter" v="0"/>
          <prop k="trim_distance_end" v="0"/>
          <prop k="trim_distance_end_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_end_unit" v="MM"/>
          <prop k="trim_distance_start" v="0"/>
          <prop k="trim_distance_start_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_start_unit" v="MM"/>
          <prop k="tweak_dash_pattern_on_corners" v="0"/>
          <prop k="use_custom_dash" v="0"/>
          <prop k="width_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <data_defined_properties>
            <Option type="Map">
              <Option type="QString" name="name" value=""/>
              <Option name="properties"/>
              <Option type="QString" name="type" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol type="line" name="20" alpha="1" clip_to_extent="1" force_rhr="0">
        <data_defined_properties>
          <Option type="Map">
            <Option type="QString" name="name" value=""/>
            <Option name="properties"/>
            <Option type="QString" name="type" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer enabled="1" locked="0" class="SimpleLine" pass="0">
          <Option type="Map">
            <Option type="QString" name="align_dash_pattern" value="0"/>
            <Option type="QString" name="capstyle" value="square"/>
            <Option type="QString" name="customdash" value="5;2"/>
            <Option type="QString" name="customdash_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="customdash_unit" value="MM"/>
            <Option type="QString" name="dash_pattern_offset" value="0"/>
            <Option type="QString" name="dash_pattern_offset_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="dash_pattern_offset_unit" value="MM"/>
            <Option type="QString" name="draw_inside_polygon" value="0"/>
            <Option type="QString" name="joinstyle" value="bevel"/>
            <Option type="QString" name="line_color" value="207,79,227,255"/>
            <Option type="QString" name="line_style" value="solid"/>
            <Option type="QString" name="line_width" value="0.26"/>
            <Option type="QString" name="line_width_unit" value="MM"/>
            <Option type="QString" name="offset" value="0"/>
            <Option type="QString" name="offset_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="offset_unit" value="MM"/>
            <Option type="QString" name="ring_filter" value="0"/>
            <Option type="QString" name="trim_distance_end" value="0"/>
            <Option type="QString" name="trim_distance_end_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="trim_distance_end_unit" value="MM"/>
            <Option type="QString" name="trim_distance_start" value="0"/>
            <Option type="QString" name="trim_distance_start_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="trim_distance_start_unit" value="MM"/>
            <Option type="QString" name="tweak_dash_pattern_on_corners" value="0"/>
            <Option type="QString" name="use_custom_dash" value="0"/>
            <Option type="QString" name="width_map_unit_scale" value="3x:0,0,0,0,0,0"/>
          </Option>
          <prop k="align_dash_pattern" v="0"/>
          <prop k="capstyle" v="square"/>
          <prop k="customdash" v="5;2"/>
          <prop k="customdash_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="customdash_unit" v="MM"/>
          <prop k="dash_pattern_offset" v="0"/>
          <prop k="dash_pattern_offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="dash_pattern_offset_unit" v="MM"/>
          <prop k="draw_inside_polygon" v="0"/>
          <prop k="joinstyle" v="bevel"/>
          <prop k="line_color" v="207,79,227,255"/>
          <prop k="line_style" v="solid"/>
          <prop k="line_width" v="0.26"/>
          <prop k="line_width_unit" v="MM"/>
          <prop k="offset" v="0"/>
          <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="offset_unit" v="MM"/>
          <prop k="ring_filter" v="0"/>
          <prop k="trim_distance_end" v="0"/>
          <prop k="trim_distance_end_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_end_unit" v="MM"/>
          <prop k="trim_distance_start" v="0"/>
          <prop k="trim_distance_start_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_start_unit" v="MM"/>
          <prop k="tweak_dash_pattern_on_corners" v="0"/>
          <prop k="use_custom_dash" v="0"/>
          <prop k="width_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <data_defined_properties>
            <Option type="Map">
              <Option type="QString" name="name" value=""/>
              <Option name="properties"/>
              <Option type="QString" name="type" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol type="line" name="3" alpha="1" clip_to_extent="1" force_rhr="0">
        <data_defined_properties>
          <Option type="Map">
            <Option type="QString" name="name" value=""/>
            <Option name="properties"/>
            <Option type="QString" name="type" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer enabled="1" locked="0" class="SimpleLine" pass="0">
          <Option type="Map">
            <Option type="QString" name="align_dash_pattern" value="0"/>
            <Option type="QString" name="capstyle" value="square"/>
            <Option type="QString" name="customdash" value="5;2"/>
            <Option type="QString" name="customdash_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="customdash_unit" value="MM"/>
            <Option type="QString" name="dash_pattern_offset" value="0"/>
            <Option type="QString" name="dash_pattern_offset_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="dash_pattern_offset_unit" value="MM"/>
            <Option type="QString" name="draw_inside_polygon" value="0"/>
            <Option type="QString" name="joinstyle" value="bevel"/>
            <Option type="QString" name="line_color" value="243,200,90,255"/>
            <Option type="QString" name="line_style" value="solid"/>
            <Option type="QString" name="line_width" value="0.575"/>
            <Option type="QString" name="line_width_unit" value="MM"/>
            <Option type="QString" name="offset" value="0"/>
            <Option type="QString" name="offset_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="offset_unit" value="MM"/>
            <Option type="QString" name="ring_filter" value="0"/>
            <Option type="QString" name="trim_distance_end" value="0"/>
            <Option type="QString" name="trim_distance_end_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="trim_distance_end_unit" value="MM"/>
            <Option type="QString" name="trim_distance_start" value="0"/>
            <Option type="QString" name="trim_distance_start_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="trim_distance_start_unit" value="MM"/>
            <Option type="QString" name="tweak_dash_pattern_on_corners" value="0"/>
            <Option type="QString" name="use_custom_dash" value="0"/>
            <Option type="QString" name="width_map_unit_scale" value="3x:0,0,0,0,0,0"/>
          </Option>
          <prop k="align_dash_pattern" v="0"/>
          <prop k="capstyle" v="square"/>
          <prop k="customdash" v="5;2"/>
          <prop k="customdash_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="customdash_unit" v="MM"/>
          <prop k="dash_pattern_offset" v="0"/>
          <prop k="dash_pattern_offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="dash_pattern_offset_unit" v="MM"/>
          <prop k="draw_inside_polygon" v="0"/>
          <prop k="joinstyle" v="bevel"/>
          <prop k="line_color" v="243,200,90,255"/>
          <prop k="line_style" v="solid"/>
          <prop k="line_width" v="0.575"/>
          <prop k="line_width_unit" v="MM"/>
          <prop k="offset" v="0"/>
          <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="offset_unit" v="MM"/>
          <prop k="ring_filter" v="0"/>
          <prop k="trim_distance_end" v="0"/>
          <prop k="trim_distance_end_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_end_unit" v="MM"/>
          <prop k="trim_distance_start" v="0"/>
          <prop k="trim_distance_start_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_start_unit" v="MM"/>
          <prop k="tweak_dash_pattern_on_corners" v="0"/>
          <prop k="use_custom_dash" v="0"/>
          <prop k="width_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <data_defined_properties>
            <Option type="Map">
              <Option type="QString" name="name" value=""/>
              <Option name="properties"/>
              <Option type="QString" name="type" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol type="line" name="4" alpha="1" clip_to_extent="1" force_rhr="0">
        <data_defined_properties>
          <Option type="Map">
            <Option type="QString" name="name" value=""/>
            <Option name="properties"/>
            <Option type="QString" name="type" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer enabled="1" locked="0" class="SimpleLine" pass="0">
          <Option type="Map">
            <Option type="QString" name="align_dash_pattern" value="0"/>
            <Option type="QString" name="capstyle" value="square"/>
            <Option type="QString" name="customdash" value="5;2"/>
            <Option type="QString" name="customdash_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="customdash_unit" value="MM"/>
            <Option type="QString" name="dash_pattern_offset" value="0"/>
            <Option type="QString" name="dash_pattern_offset_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="dash_pattern_offset_unit" value="MM"/>
            <Option type="QString" name="draw_inside_polygon" value="0"/>
            <Option type="QString" name="joinstyle" value="bevel"/>
            <Option type="QString" name="line_color" value="243,200,90,255"/>
            <Option type="QString" name="line_style" value="solid"/>
            <Option type="QString" name="line_width" value="0.8125"/>
            <Option type="QString" name="line_width_unit" value="MM"/>
            <Option type="QString" name="offset" value="0"/>
            <Option type="QString" name="offset_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="offset_unit" value="MM"/>
            <Option type="QString" name="ring_filter" value="0"/>
            <Option type="QString" name="trim_distance_end" value="0"/>
            <Option type="QString" name="trim_distance_end_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="trim_distance_end_unit" value="MM"/>
            <Option type="QString" name="trim_distance_start" value="0"/>
            <Option type="QString" name="trim_distance_start_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="trim_distance_start_unit" value="MM"/>
            <Option type="QString" name="tweak_dash_pattern_on_corners" value="0"/>
            <Option type="QString" name="use_custom_dash" value="0"/>
            <Option type="QString" name="width_map_unit_scale" value="3x:0,0,0,0,0,0"/>
          </Option>
          <prop k="align_dash_pattern" v="0"/>
          <prop k="capstyle" v="square"/>
          <prop k="customdash" v="5;2"/>
          <prop k="customdash_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="customdash_unit" v="MM"/>
          <prop k="dash_pattern_offset" v="0"/>
          <prop k="dash_pattern_offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="dash_pattern_offset_unit" v="MM"/>
          <prop k="draw_inside_polygon" v="0"/>
          <prop k="joinstyle" v="bevel"/>
          <prop k="line_color" v="243,200,90,255"/>
          <prop k="line_style" v="solid"/>
          <prop k="line_width" v="0.8125"/>
          <prop k="line_width_unit" v="MM"/>
          <prop k="offset" v="0"/>
          <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="offset_unit" v="MM"/>
          <prop k="ring_filter" v="0"/>
          <prop k="trim_distance_end" v="0"/>
          <prop k="trim_distance_end_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_end_unit" v="MM"/>
          <prop k="trim_distance_start" v="0"/>
          <prop k="trim_distance_start_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_start_unit" v="MM"/>
          <prop k="tweak_dash_pattern_on_corners" v="0"/>
          <prop k="use_custom_dash" v="0"/>
          <prop k="width_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <data_defined_properties>
            <Option type="Map">
              <Option type="QString" name="name" value=""/>
              <Option name="properties"/>
              <Option type="QString" name="type" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol type="line" name="5" alpha="1" clip_to_extent="1" force_rhr="0">
        <data_defined_properties>
          <Option type="Map">
            <Option type="QString" name="name" value=""/>
            <Option name="properties"/>
            <Option type="QString" name="type" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer enabled="1" locked="0" class="SimpleLine" pass="0">
          <Option type="Map">
            <Option type="QString" name="align_dash_pattern" value="0"/>
            <Option type="QString" name="capstyle" value="square"/>
            <Option type="QString" name="customdash" value="5;2"/>
            <Option type="QString" name="customdash_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="customdash_unit" value="MM"/>
            <Option type="QString" name="dash_pattern_offset" value="0"/>
            <Option type="QString" name="dash_pattern_offset_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="dash_pattern_offset_unit" value="MM"/>
            <Option type="QString" name="draw_inside_polygon" value="0"/>
            <Option type="QString" name="joinstyle" value="bevel"/>
            <Option type="QString" name="line_color" value="243,200,90,255"/>
            <Option type="QString" name="line_style" value="solid"/>
            <Option type="QString" name="line_width" value="1.05"/>
            <Option type="QString" name="line_width_unit" value="MM"/>
            <Option type="QString" name="offset" value="0"/>
            <Option type="QString" name="offset_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="offset_unit" value="MM"/>
            <Option type="QString" name="ring_filter" value="0"/>
            <Option type="QString" name="trim_distance_end" value="0"/>
            <Option type="QString" name="trim_distance_end_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="trim_distance_end_unit" value="MM"/>
            <Option type="QString" name="trim_distance_start" value="0"/>
            <Option type="QString" name="trim_distance_start_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="trim_distance_start_unit" value="MM"/>
            <Option type="QString" name="tweak_dash_pattern_on_corners" value="0"/>
            <Option type="QString" name="use_custom_dash" value="0"/>
            <Option type="QString" name="width_map_unit_scale" value="3x:0,0,0,0,0,0"/>
          </Option>
          <prop k="align_dash_pattern" v="0"/>
          <prop k="capstyle" v="square"/>
          <prop k="customdash" v="5;2"/>
          <prop k="customdash_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="customdash_unit" v="MM"/>
          <prop k="dash_pattern_offset" v="0"/>
          <prop k="dash_pattern_offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="dash_pattern_offset_unit" v="MM"/>
          <prop k="draw_inside_polygon" v="0"/>
          <prop k="joinstyle" v="bevel"/>
          <prop k="line_color" v="243,200,90,255"/>
          <prop k="line_style" v="solid"/>
          <prop k="line_width" v="1.05"/>
          <prop k="line_width_unit" v="MM"/>
          <prop k="offset" v="0"/>
          <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="offset_unit" v="MM"/>
          <prop k="ring_filter" v="0"/>
          <prop k="trim_distance_end" v="0"/>
          <prop k="trim_distance_end_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_end_unit" v="MM"/>
          <prop k="trim_distance_start" v="0"/>
          <prop k="trim_distance_start_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_start_unit" v="MM"/>
          <prop k="tweak_dash_pattern_on_corners" v="0"/>
          <prop k="use_custom_dash" v="0"/>
          <prop k="width_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <data_defined_properties>
            <Option type="Map">
              <Option type="QString" name="name" value=""/>
              <Option name="properties"/>
              <Option type="QString" name="type" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol type="line" name="6" alpha="1" clip_to_extent="1" force_rhr="0">
        <data_defined_properties>
          <Option type="Map">
            <Option type="QString" name="name" value=""/>
            <Option name="properties"/>
            <Option type="QString" name="type" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer enabled="1" locked="0" class="SimpleLine" pass="0">
          <Option type="Map">
            <Option type="QString" name="align_dash_pattern" value="0"/>
            <Option type="QString" name="capstyle" value="square"/>
            <Option type="QString" name="customdash" value="5;2"/>
            <Option type="QString" name="customdash_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="customdash_unit" value="MM"/>
            <Option type="QString" name="dash_pattern_offset" value="0"/>
            <Option type="QString" name="dash_pattern_offset_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="dash_pattern_offset_unit" value="MM"/>
            <Option type="QString" name="draw_inside_polygon" value="0"/>
            <Option type="QString" name="joinstyle" value="bevel"/>
            <Option type="QString" name="line_color" value="243,200,90,255"/>
            <Option type="QString" name="line_style" value="solid"/>
            <Option type="QString" name="line_width" value="1.2875"/>
            <Option type="QString" name="line_width_unit" value="MM"/>
            <Option type="QString" name="offset" value="0"/>
            <Option type="QString" name="offset_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="offset_unit" value="MM"/>
            <Option type="QString" name="ring_filter" value="0"/>
            <Option type="QString" name="trim_distance_end" value="0"/>
            <Option type="QString" name="trim_distance_end_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="trim_distance_end_unit" value="MM"/>
            <Option type="QString" name="trim_distance_start" value="0"/>
            <Option type="QString" name="trim_distance_start_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="trim_distance_start_unit" value="MM"/>
            <Option type="QString" name="tweak_dash_pattern_on_corners" value="0"/>
            <Option type="QString" name="use_custom_dash" value="0"/>
            <Option type="QString" name="width_map_unit_scale" value="3x:0,0,0,0,0,0"/>
          </Option>
          <prop k="align_dash_pattern" v="0"/>
          <prop k="capstyle" v="square"/>
          <prop k="customdash" v="5;2"/>
          <prop k="customdash_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="customdash_unit" v="MM"/>
          <prop k="dash_pattern_offset" v="0"/>
          <prop k="dash_pattern_offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="dash_pattern_offset_unit" v="MM"/>
          <prop k="draw_inside_polygon" v="0"/>
          <prop k="joinstyle" v="bevel"/>
          <prop k="line_color" v="243,200,90,255"/>
          <prop k="line_style" v="solid"/>
          <prop k="line_width" v="1.2875"/>
          <prop k="line_width_unit" v="MM"/>
          <prop k="offset" v="0"/>
          <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="offset_unit" v="MM"/>
          <prop k="ring_filter" v="0"/>
          <prop k="trim_distance_end" v="0"/>
          <prop k="trim_distance_end_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_end_unit" v="MM"/>
          <prop k="trim_distance_start" v="0"/>
          <prop k="trim_distance_start_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_start_unit" v="MM"/>
          <prop k="tweak_dash_pattern_on_corners" v="0"/>
          <prop k="use_custom_dash" v="0"/>
          <prop k="width_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <data_defined_properties>
            <Option type="Map">
              <Option type="QString" name="name" value=""/>
              <Option name="properties"/>
              <Option type="QString" name="type" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol type="line" name="7" alpha="1" clip_to_extent="1" force_rhr="0">
        <data_defined_properties>
          <Option type="Map">
            <Option type="QString" name="name" value=""/>
            <Option name="properties"/>
            <Option type="QString" name="type" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer enabled="1" locked="0" class="SimpleLine" pass="0">
          <Option type="Map">
            <Option type="QString" name="align_dash_pattern" value="0"/>
            <Option type="QString" name="capstyle" value="square"/>
            <Option type="QString" name="customdash" value="5;2"/>
            <Option type="QString" name="customdash_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="customdash_unit" value="MM"/>
            <Option type="QString" name="dash_pattern_offset" value="0"/>
            <Option type="QString" name="dash_pattern_offset_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="dash_pattern_offset_unit" value="MM"/>
            <Option type="QString" name="draw_inside_polygon" value="0"/>
            <Option type="QString" name="joinstyle" value="bevel"/>
            <Option type="QString" name="line_color" value="243,200,90,255"/>
            <Option type="QString" name="line_style" value="solid"/>
            <Option type="QString" name="line_width" value="1.525"/>
            <Option type="QString" name="line_width_unit" value="MM"/>
            <Option type="QString" name="offset" value="0"/>
            <Option type="QString" name="offset_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="offset_unit" value="MM"/>
            <Option type="QString" name="ring_filter" value="0"/>
            <Option type="QString" name="trim_distance_end" value="0"/>
            <Option type="QString" name="trim_distance_end_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="trim_distance_end_unit" value="MM"/>
            <Option type="QString" name="trim_distance_start" value="0"/>
            <Option type="QString" name="trim_distance_start_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="trim_distance_start_unit" value="MM"/>
            <Option type="QString" name="tweak_dash_pattern_on_corners" value="0"/>
            <Option type="QString" name="use_custom_dash" value="0"/>
            <Option type="QString" name="width_map_unit_scale" value="3x:0,0,0,0,0,0"/>
          </Option>
          <prop k="align_dash_pattern" v="0"/>
          <prop k="capstyle" v="square"/>
          <prop k="customdash" v="5;2"/>
          <prop k="customdash_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="customdash_unit" v="MM"/>
          <prop k="dash_pattern_offset" v="0"/>
          <prop k="dash_pattern_offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="dash_pattern_offset_unit" v="MM"/>
          <prop k="draw_inside_polygon" v="0"/>
          <prop k="joinstyle" v="bevel"/>
          <prop k="line_color" v="243,200,90,255"/>
          <prop k="line_style" v="solid"/>
          <prop k="line_width" v="1.525"/>
          <prop k="line_width_unit" v="MM"/>
          <prop k="offset" v="0"/>
          <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="offset_unit" v="MM"/>
          <prop k="ring_filter" v="0"/>
          <prop k="trim_distance_end" v="0"/>
          <prop k="trim_distance_end_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_end_unit" v="MM"/>
          <prop k="trim_distance_start" v="0"/>
          <prop k="trim_distance_start_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_start_unit" v="MM"/>
          <prop k="tweak_dash_pattern_on_corners" v="0"/>
          <prop k="use_custom_dash" v="0"/>
          <prop k="width_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <data_defined_properties>
            <Option type="Map">
              <Option type="QString" name="name" value=""/>
              <Option name="properties"/>
              <Option type="QString" name="type" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol type="line" name="8" alpha="1" clip_to_extent="1" force_rhr="0">
        <data_defined_properties>
          <Option type="Map">
            <Option type="QString" name="name" value=""/>
            <Option name="properties"/>
            <Option type="QString" name="type" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer enabled="1" locked="0" class="SimpleLine" pass="0">
          <Option type="Map">
            <Option type="QString" name="align_dash_pattern" value="0"/>
            <Option type="QString" name="capstyle" value="square"/>
            <Option type="QString" name="customdash" value="5;2"/>
            <Option type="QString" name="customdash_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="customdash_unit" value="MM"/>
            <Option type="QString" name="dash_pattern_offset" value="0"/>
            <Option type="QString" name="dash_pattern_offset_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="dash_pattern_offset_unit" value="MM"/>
            <Option type="QString" name="draw_inside_polygon" value="0"/>
            <Option type="QString" name="joinstyle" value="bevel"/>
            <Option type="QString" name="line_color" value="243,200,90,255"/>
            <Option type="QString" name="line_style" value="solid"/>
            <Option type="QString" name="line_width" value="1.525"/>
            <Option type="QString" name="line_width_unit" value="MM"/>
            <Option type="QString" name="offset" value="0"/>
            <Option type="QString" name="offset_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="offset_unit" value="MM"/>
            <Option type="QString" name="ring_filter" value="0"/>
            <Option type="QString" name="trim_distance_end" value="0"/>
            <Option type="QString" name="trim_distance_end_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="trim_distance_end_unit" value="MM"/>
            <Option type="QString" name="trim_distance_start" value="0"/>
            <Option type="QString" name="trim_distance_start_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="trim_distance_start_unit" value="MM"/>
            <Option type="QString" name="tweak_dash_pattern_on_corners" value="0"/>
            <Option type="QString" name="use_custom_dash" value="0"/>
            <Option type="QString" name="width_map_unit_scale" value="3x:0,0,0,0,0,0"/>
          </Option>
          <prop k="align_dash_pattern" v="0"/>
          <prop k="capstyle" v="square"/>
          <prop k="customdash" v="5;2"/>
          <prop k="customdash_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="customdash_unit" v="MM"/>
          <prop k="dash_pattern_offset" v="0"/>
          <prop k="dash_pattern_offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="dash_pattern_offset_unit" v="MM"/>
          <prop k="draw_inside_polygon" v="0"/>
          <prop k="joinstyle" v="bevel"/>
          <prop k="line_color" v="243,200,90,255"/>
          <prop k="line_style" v="solid"/>
          <prop k="line_width" v="1.525"/>
          <prop k="line_width_unit" v="MM"/>
          <prop k="offset" v="0"/>
          <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="offset_unit" v="MM"/>
          <prop k="ring_filter" v="0"/>
          <prop k="trim_distance_end" v="0"/>
          <prop k="trim_distance_end_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_end_unit" v="MM"/>
          <prop k="trim_distance_start" v="0"/>
          <prop k="trim_distance_start_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_start_unit" v="MM"/>
          <prop k="tweak_dash_pattern_on_corners" v="0"/>
          <prop k="use_custom_dash" v="0"/>
          <prop k="width_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <data_defined_properties>
            <Option type="Map">
              <Option type="QString" name="name" value=""/>
              <Option name="properties"/>
              <Option type="QString" name="type" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol type="line" name="9" alpha="1" clip_to_extent="1" force_rhr="0">
        <data_defined_properties>
          <Option type="Map">
            <Option type="QString" name="name" value=""/>
            <Option name="properties"/>
            <Option type="QString" name="type" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer enabled="1" locked="0" class="SimpleLine" pass="0">
          <Option type="Map">
            <Option type="QString" name="align_dash_pattern" value="0"/>
            <Option type="QString" name="capstyle" value="square"/>
            <Option type="QString" name="customdash" value="5;2"/>
            <Option type="QString" name="customdash_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="customdash_unit" value="MM"/>
            <Option type="QString" name="dash_pattern_offset" value="0"/>
            <Option type="QString" name="dash_pattern_offset_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="dash_pattern_offset_unit" value="MM"/>
            <Option type="QString" name="draw_inside_polygon" value="0"/>
            <Option type="QString" name="joinstyle" value="bevel"/>
            <Option type="QString" name="line_color" value="243,200,90,255"/>
            <Option type="QString" name="line_style" value="solid"/>
            <Option type="QString" name="line_width" value="1.525"/>
            <Option type="QString" name="line_width_unit" value="MM"/>
            <Option type="QString" name="offset" value="0"/>
            <Option type="QString" name="offset_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="offset_unit" value="MM"/>
            <Option type="QString" name="ring_filter" value="0"/>
            <Option type="QString" name="trim_distance_end" value="0"/>
            <Option type="QString" name="trim_distance_end_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="trim_distance_end_unit" value="MM"/>
            <Option type="QString" name="trim_distance_start" value="0"/>
            <Option type="QString" name="trim_distance_start_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="trim_distance_start_unit" value="MM"/>
            <Option type="QString" name="tweak_dash_pattern_on_corners" value="0"/>
            <Option type="QString" name="use_custom_dash" value="0"/>
            <Option type="QString" name="width_map_unit_scale" value="3x:0,0,0,0,0,0"/>
          </Option>
          <prop k="align_dash_pattern" v="0"/>
          <prop k="capstyle" v="square"/>
          <prop k="customdash" v="5;2"/>
          <prop k="customdash_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="customdash_unit" v="MM"/>
          <prop k="dash_pattern_offset" v="0"/>
          <prop k="dash_pattern_offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="dash_pattern_offset_unit" v="MM"/>
          <prop k="draw_inside_polygon" v="0"/>
          <prop k="joinstyle" v="bevel"/>
          <prop k="line_color" v="243,200,90,255"/>
          <prop k="line_style" v="solid"/>
          <prop k="line_width" v="1.525"/>
          <prop k="line_width_unit" v="MM"/>
          <prop k="offset" v="0"/>
          <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="offset_unit" v="MM"/>
          <prop k="ring_filter" v="0"/>
          <prop k="trim_distance_end" v="0"/>
          <prop k="trim_distance_end_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_end_unit" v="MM"/>
          <prop k="trim_distance_start" v="0"/>
          <prop k="trim_distance_start_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_start_unit" v="MM"/>
          <prop k="tweak_dash_pattern_on_corners" v="0"/>
          <prop k="use_custom_dash" v="0"/>
          <prop k="width_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <data_defined_properties>
            <Option type="Map">
              <Option type="QString" name="name" value=""/>
              <Option name="properties"/>
              <Option type="QString" name="type" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
    </symbols>
  </renderer-v2>
  <customproperties>
    <Option type="Map">
      <Option type="List" name="dualview/previewExpressions">
        <Option type="QString" value="&quot;GNIS_Name&quot;"/>
      </Option>
      <Option type="int" name="embeddedWidgets/count" value="0"/>
      <Option name="variableNames"/>
      <Option name="variableValues"/>
    </Option>
  </customproperties>
  <blendMode>0</blendMode>
  <featureBlendMode>0</featureBlendMode>
  <layerOpacity>1</layerOpacity>
  <SingleCategoryDiagramRenderer attributeLegend="1" diagramType="Histogram">
    <DiagramCategory direction="0" penWidth="0" width="15" opacity="1" sizeScale="3x:0,0,0,0,0,0" diagramOrientation="Up" maxScaleDenominator="1e+08" minScaleDenominator="0" barWidth="5" scaleBasedVisibility="0" spacing="5" height="15" scaleDependency="Area" lineSizeType="MM" penColor="#000000" spacingUnit="MM" penAlpha="255" backgroundColor="#ffffff" lineSizeScale="3x:0,0,0,0,0,0" enabled="0" sizeType="MM" labelPlacementMethod="XHeight" showAxis="1" rotationOffset="270" backgroundAlpha="255" minimumSize="0" spacingUnitScale="3x:0,0,0,0,0,0">
      <fontProperties description="MS Shell Dlg 2,9.5,-1,5,50,0,0,0,0,0" style=""/>
      <attribute field="" label="" color="#000000"/>
      <axisSymbol>
        <symbol type="line" name="" alpha="1" clip_to_extent="1" force_rhr="0">
          <data_defined_properties>
            <Option type="Map">
              <Option type="QString" name="name" value=""/>
              <Option name="properties"/>
              <Option type="QString" name="type" value="collection"/>
            </Option>
          </data_defined_properties>
          <layer enabled="1" locked="0" class="SimpleLine" pass="0">
            <Option type="Map">
              <Option type="QString" name="align_dash_pattern" value="0"/>
              <Option type="QString" name="capstyle" value="square"/>
              <Option type="QString" name="customdash" value="5;2"/>
              <Option type="QString" name="customdash_map_unit_scale" value="3x:0,0,0,0,0,0"/>
              <Option type="QString" name="customdash_unit" value="MM"/>
              <Option type="QString" name="dash_pattern_offset" value="0"/>
              <Option type="QString" name="dash_pattern_offset_map_unit_scale" value="3x:0,0,0,0,0,0"/>
              <Option type="QString" name="dash_pattern_offset_unit" value="MM"/>
              <Option type="QString" name="draw_inside_polygon" value="0"/>
              <Option type="QString" name="joinstyle" value="bevel"/>
              <Option type="QString" name="line_color" value="35,35,35,255"/>
              <Option type="QString" name="line_style" value="solid"/>
              <Option type="QString" name="line_width" value="0.26"/>
              <Option type="QString" name="line_width_unit" value="MM"/>
              <Option type="QString" name="offset" value="0"/>
              <Option type="QString" name="offset_map_unit_scale" value="3x:0,0,0,0,0,0"/>
              <Option type="QString" name="offset_unit" value="MM"/>
              <Option type="QString" name="ring_filter" value="0"/>
              <Option type="QString" name="trim_distance_end" value="0"/>
              <Option type="QString" name="trim_distance_end_map_unit_scale" value="3x:0,0,0,0,0,0"/>
              <Option type="QString" name="trim_distance_end_unit" value="MM"/>
              <Option type="QString" name="trim_distance_start" value="0"/>
              <Option type="QString" name="trim_distance_start_map_unit_scale" value="3x:0,0,0,0,0,0"/>
              <Option type="QString" name="trim_distance_start_unit" value="MM"/>
              <Option type="QString" name="tweak_dash_pattern_on_corners" value="0"/>
              <Option type="QString" name="use_custom_dash" value="0"/>
              <Option type="QString" name="width_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            </Option>
            <prop k="align_dash_pattern" v="0"/>
            <prop k="capstyle" v="square"/>
            <prop k="customdash" v="5;2"/>
            <prop k="customdash_map_unit_scale" v="3x:0,0,0,0,0,0"/>
            <prop k="customdash_unit" v="MM"/>
            <prop k="dash_pattern_offset" v="0"/>
            <prop k="dash_pattern_offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
            <prop k="dash_pattern_offset_unit" v="MM"/>
            <prop k="draw_inside_polygon" v="0"/>
            <prop k="joinstyle" v="bevel"/>
            <prop k="line_color" v="35,35,35,255"/>
            <prop k="line_style" v="solid"/>
            <prop k="line_width" v="0.26"/>
            <prop k="line_width_unit" v="MM"/>
            <prop k="offset" v="0"/>
            <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
            <prop k="offset_unit" v="MM"/>
            <prop k="ring_filter" v="0"/>
            <prop k="trim_distance_end" v="0"/>
            <prop k="trim_distance_end_map_unit_scale" v="3x:0,0,0,0,0,0"/>
            <prop k="trim_distance_end_unit" v="MM"/>
            <prop k="trim_distance_start" v="0"/>
            <prop k="trim_distance_start_map_unit_scale" v="3x:0,0,0,0,0,0"/>
            <prop k="trim_distance_start_unit" v="MM"/>
            <prop k="tweak_dash_pattern_on_corners" v="0"/>
            <prop k="use_custom_dash" v="0"/>
            <prop k="width_map_unit_scale" v="3x:0,0,0,0,0,0"/>
            <data_defined_properties>
              <Option type="Map">
                <Option type="QString" name="name" value=""/>
                <Option name="properties"/>
                <Option type="QString" name="type" value="collection"/>
              </Option>
            </data_defined_properties>
          </layer>
        </symbol>
      </axisSymbol>
    </DiagramCategory>
  </SingleCategoryDiagramRenderer>
  <DiagramLayerSettings placement="2" linePlacementFlags="18" priority="0" zIndex="0" showAll="1" obstacle="0" dist="0">
    <properties>
      <Option type="Map">
        <Option type="QString" name="name" value=""/>
        <Option name="properties"/>
        <Option type="QString" name="type" value="collection"/>
      </Option>
    </properties>
  </DiagramLayerSettings>
  <geometryOptions removeDuplicateNodes="0" geometryPrecision="0">
    <activeChecks/>
    <checkConfiguration/>
  </geometryOptions>
  <legend type="default-vector" showLabelLegend="0"/>
  <referencedLayers/>
  <fieldConfiguration>
    <field configurationFlags="None" name="OBJECTID">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="Permanent_Identifier">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="FDate">
      <editWidget type="DateTime">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="Resolution">
      <editWidget type="ValueMap">
        <config>
          <Option type="Map">
            <Option type="List" name="map">
              <Option type="Map">
                <Option type="QString" name="Local" value="1"/>
              </Option>
              <Option type="Map">
                <Option type="QString" name="High" value="2"/>
              </Option>
              <Option type="Map">
                <Option type="QString" name="Medium" value="3"/>
              </Option>
            </Option>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="GNIS_ID">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="GNIS_Name">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="LengthKM">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="ReachCode">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="FlowDir">
      <editWidget type="ValueMap">
        <config>
          <Option type="Map">
            <Option type="List" name="map">
              <Option type="Map">
                <Option type="QString" name="Uninitialized" value="0"/>
              </Option>
              <Option type="Map">
                <Option type="QString" name="WithDigitized" value="1"/>
              </Option>
            </Option>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="WBArea_Permanent_Identifier">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="FType">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="FCode">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="MainPath">
      <editWidget type="ValueMap">
        <config>
          <Option type="Map">
            <Option type="List" name="map">
              <Option type="Map">
                <Option type="QString" name="Unspecified" value="0"/>
              </Option>
              <Option type="Map">
                <Option type="QString" name="Confluence Main" value="1"/>
              </Option>
              <Option type="Map">
                <Option type="QString" name="Divergence Main" value="2"/>
              </Option>
              <Option type="Map">
                <Option type="QString" name="Both Confluence and Divergence Main" value="3"/>
              </Option>
            </Option>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="InNetwork">
      <editWidget type="ValueMap">
        <config>
          <Option type="Map">
            <Option type="List" name="map">
              <Option type="Map">
                <Option type="QString" name="Yes" value="1"/>
              </Option>
              <Option type="Map">
                <Option type="QString" name="No" value="0"/>
              </Option>
            </Option>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="VisibilityFilter">
      <editWidget type="ValueMap">
        <config>
          <Option type="Map">
            <Option type="List" name="map">
              <Option type="Map">
                <Option type="QString" name="Unspecified" value="0"/>
              </Option>
              <Option type="Map">
                <Option type="QString" name="Approximately 1:4,800 or Larger Scale" value="4800"/>
              </Option>
              <Option type="Map">
                <Option type="QString" name="Approximately 1:12,500 or Larger Scale" value="12500"/>
              </Option>
              <Option type="Map">
                <Option type="QString" name="Approximately 1:24,000 or Larger Scale" value="24000"/>
              </Option>
              <Option type="Map">
                <Option type="QString" name="Approximately 1:50,000 or Larger Scale" value="50000"/>
              </Option>
              <Option type="Map">
                <Option type="QString" name="Approximately 1:100,000 or Larger Scale" value="100000"/>
              </Option>
              <Option type="Map">
                <Option type="QString" name="Approximately 1:150,000 or Larger Scale" value="150000"/>
              </Option>
              <Option type="Map">
                <Option type="QString" name="Approximately 1:250,000 or Larger Scale" value="250000"/>
              </Option>
              <Option type="Map">
                <Option type="QString" name="Approximately 1:500,000 or Larger Scale" value="500000"/>
              </Option>
              <Option type="Map">
                <Option type="QString" name="Approximately 1:1,000,000 or Larger Scale" value="1000000"/>
              </Option>
              <Option type="Map">
                <Option type="QString" name="Approximately 1:2,000,000 or Larger Scale" value="2000000"/>
              </Option>
              <Option type="Map">
                <Option type="QString" name="Approximately 1:5,000,000 or Larger Scale" value="5000000"/>
              </Option>
            </Option>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="Shape_Length">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="NHDPlusID">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="VPUID">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="Enabled">
      <editWidget type="ValueMap">
        <config>
          <Option type="Map">
            <Option type="List" name="map">
              <Option type="Map">
                <Option type="QString" name="False" value="0"/>
              </Option>
              <Option type="Map">
                <Option type="QString" name="True" value="1"/>
              </Option>
            </Option>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="StreamOrde">
      <editWidget type="Range">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="HydroSeq">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="FromNode">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="ToNode">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="Q_cms">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="width_m">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="depth_m">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="wtd_m_min">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="wtd_m_median">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="wtd_m_mean">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="wtd_m_max">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="perenniality">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
  </fieldConfiguration>
  <aliases>
    <alias name="" field="OBJECTID" index="0"/>
    <alias name="" field="Permanent_Identifier" index="1"/>
    <alias name="" field="FDate" index="2"/>
    <alias name="" field="Resolution" index="3"/>
    <alias name="" field="GNIS_ID" index="4"/>
    <alias name="" field="GNIS_Name" index="5"/>
    <alias name="" field="LengthKM" index="6"/>
    <alias name="" field="ReachCode" index="7"/>
    <alias name="" field="FlowDir" index="8"/>
    <alias name="" field="WBArea_Permanent_Identifier" index="9"/>
    <alias name="" field="FType" index="10"/>
    <alias name="" field="FCode" index="11"/>
    <alias name="" field="MainPath" index="12"/>
    <alias name="" field="InNetwork" index="13"/>
    <alias name="" field="VisibilityFilter" index="14"/>
    <alias name="" field="Shape_Length" index="15"/>
    <alias name="" field="NHDPlusID" index="16"/>
    <alias name="" field="VPUID" index="17"/>
    <alias name="" field="Enabled" index="18"/>
    <alias name="" field="StreamOrde" index="19"/>
    <alias name="" field="HydroSeq" index="20"/>
    <alias name="" field="FromNode" index="21"/>
    <alias name="" field="ToNode" index="22"/>
    <alias name="" field="Q_cms" index="23"/>
    <alias name="" field="width_m" index="24"/>
    <alias name="" field="depth_m" index="25"/>
    <alias name="" field="wtd_m_min" index="26"/>
    <alias name="" field="wtd_m_median" index="27"/>
    <alias name="" field="wtd_m_mean" index="28"/>
    <alias name="" field="wtd_m_max" index="29"/>
    <alias name="" field="perenniality" index="30"/>
  </aliases>
  <defaults>
    <default field="OBJECTID" expression="" applyOnUpdate="0"/>
    <default field="Permanent_Identifier" expression="" applyOnUpdate="0"/>
    <default field="FDate" expression="" applyOnUpdate="0"/>
    <default field="Resolution" expression="" applyOnUpdate="0"/>
    <default field="GNIS_ID" expression="" applyOnUpdate="0"/>
    <default field="GNIS_Name" expression="" applyOnUpdate="0"/>
    <default field="LengthKM" expression="" applyOnUpdate="0"/>
    <default field="ReachCode" expression="" applyOnUpdate="0"/>
    <default field="FlowDir" expression="" applyOnUpdate="0"/>
    <default field="WBArea_Permanent_Identifier" expression="" applyOnUpdate="0"/>
    <default field="FType" expression="" applyOnUpdate="0"/>
    <default field="FCode" expression="" applyOnUpdate="0"/>
    <default field="MainPath" expression="" applyOnUpdate="0"/>
    <default field="InNetwork" expression="" applyOnUpdate="0"/>
    <default field="VisibilityFilter" expression="" applyOnUpdate="0"/>
    <default field="Shape_Length" expression="" applyOnUpdate="0"/>
    <default field="NHDPlusID" expression="" applyOnUpdate="0"/>
    <default field="VPUID" expression="" applyOnUpdate="0"/>
    <default field="Enabled" expression="" applyOnUpdate="0"/>
    <default field="StreamOrde" expression="" applyOnUpdate="0"/>
    <default field="HydroSeq" expression="" applyOnUpdate="0"/>
    <default field="FromNode" expression="" applyOnUpdate="0"/>
    <default field="ToNode" expression="" applyOnUpdate="0"/>
    <default field="Q_cms" expression="" applyOnUpdate="0"/>
    <default field="width_m" expression="" applyOnUpdate="0"/>
    <default field="depth_m" expression="" applyOnUpdate="0"/>
    <default field="wtd_m_min" expression="" applyOnUpdate="0"/>
    <default field="wtd_m_median" expression="" applyOnUpdate="0"/>
    <default field="wtd_m_mean" expression="" applyOnUpdate="0"/>
    <default field="wtd_m_max" expression="" applyOnUpdate="0"/>
    <default field="perenniality" expression="" applyOnUpdate="0"/>
  </defaults>
  <constraints>
    <constraint notnull_strength="1" exp_strength="0" field="OBJECTID" constraints="3" unique_strength="1"/>
    <constraint notnull_strength="1" exp_strength="0" field="Permanent_Identifier" constraints="1" unique_strength="0"/>
    <constraint notnull_strength="1" exp_strength="0" field="FDate" constraints="1" unique_strength="0"/>
    <constraint notnull_strength="1" exp_strength="0" field="Resolution" constraints="1" unique_strength="0"/>
    <constraint notnull_strength="0" exp_strength="0" field="GNIS_ID" constraints="0" unique_strength="0"/>
    <constraint notnull_strength="0" exp_strength="0" field="GNIS_Name" constraints="0" unique_strength="0"/>
    <constraint notnull_strength="0" exp_strength="0" field="LengthKM" constraints="0" unique_strength="0"/>
    <constraint notnull_strength="0" exp_strength="0" field="ReachCode" constraints="0" unique_strength="0"/>
    <constraint notnull_strength="1" exp_strength="0" field="FlowDir" constraints="1" unique_strength="0"/>
    <constraint notnull_strength="0" exp_strength="0" field="WBArea_Permanent_Identifier" constraints="0" unique_strength="0"/>
    <constraint notnull_strength="1" exp_strength="0" field="FType" constraints="1" unique_strength="0"/>
    <constraint notnull_strength="0" exp_strength="0" field="FCode" constraints="0" unique_strength="0"/>
    <constraint notnull_strength="1" exp_strength="0" field="MainPath" constraints="1" unique_strength="0"/>
    <constraint notnull_strength="1" exp_strength="0" field="InNetwork" constraints="1" unique_strength="0"/>
    <constraint notnull_strength="1" exp_strength="0" field="VisibilityFilter" constraints="1" unique_strength="0"/>
    <constraint notnull_strength="0" exp_strength="0" field="Shape_Length" constraints="0" unique_strength="0"/>
    <constraint notnull_strength="0" exp_strength="0" field="NHDPlusID" constraints="0" unique_strength="0"/>
    <constraint notnull_strength="0" exp_strength="0" field="VPUID" constraints="0" unique_strength="0"/>
    <constraint notnull_strength="0" exp_strength="0" field="Enabled" constraints="0" unique_strength="0"/>
    <constraint notnull_strength="0" exp_strength="0" field="StreamOrde" constraints="0" unique_strength="0"/>
    <constraint notnull_strength="0" exp_strength="0" field="HydroSeq" constraints="0" unique_strength="0"/>
    <constraint notnull_strength="0" exp_strength="0" field="FromNode" constraints="0" unique_strength="0"/>
    <constraint notnull_strength="0" exp_strength="0" field="ToNode" constraints="0" unique_strength="0"/>
    <constraint notnull_strength="0" exp_strength="0" field="Q_cms" constraints="0" unique_strength="0"/>
    <constraint notnull_strength="0" exp_strength="0" field="width_m" constraints="0" unique_strength="0"/>
    <constraint notnull_strength="0" exp_strength="0" field="depth_m" constraints="0" unique_strength="0"/>
    <constraint notnull_strength="0" exp_strength="0" field="wtd_m_min" constraints="0" unique_strength="0"/>
    <constraint notnull_strength="0" exp_strength="0" field="wtd_m_median" constraints="0" unique_strength="0"/>
    <constraint notnull_strength="0" exp_strength="0" field="wtd_m_mean" constraints="0" unique_strength="0"/>
    <constraint notnull_strength="0" exp_strength="0" field="wtd_m_max" constraints="0" unique_strength="0"/>
    <constraint notnull_strength="0" exp_strength="0" field="perenniality" constraints="0" unique_strength="0"/>
  </constraints>
  <constraintExpressions>
    <constraint field="OBJECTID" desc="" exp=""/>
    <constraint field="Permanent_Identifier" desc="" exp=""/>
    <constraint field="FDate" desc="" exp=""/>
    <constraint field="Resolution" desc="" exp=""/>
    <constraint field="GNIS_ID" desc="" exp=""/>
    <constraint field="GNIS_Name" desc="" exp=""/>
    <constraint field="LengthKM" desc="" exp=""/>
    <constraint field="ReachCode" desc="" exp=""/>
    <constraint field="FlowDir" desc="" exp=""/>
    <constraint field="WBArea_Permanent_Identifier" desc="" exp=""/>
    <constraint field="FType" desc="" exp=""/>
    <constraint field="FCode" desc="" exp=""/>
    <constraint field="MainPath" desc="" exp=""/>
    <constraint field="InNetwork" desc="" exp=""/>
    <constraint field="VisibilityFilter" desc="" exp=""/>
    <constraint field="Shape_Length" desc="" exp=""/>
    <constraint field="NHDPlusID" desc="" exp=""/>
    <constraint field="VPUID" desc="" exp=""/>
    <constraint field="Enabled" desc="" exp=""/>
    <constraint field="StreamOrde" desc="" exp=""/>
    <constraint field="HydroSeq" desc="" exp=""/>
    <constraint field="FromNode" desc="" exp=""/>
    <constraint field="ToNode" desc="" exp=""/>
    <constraint field="Q_cms" desc="" exp=""/>
    <constraint field="width_m" desc="" exp=""/>
    <constraint field="depth_m" desc="" exp=""/>
    <constraint field="wtd_m_min" desc="" exp=""/>
    <constraint field="wtd_m_median" desc="" exp=""/>
    <constraint field="wtd_m_mean" desc="" exp=""/>
    <constraint field="wtd_m_max" desc="" exp=""/>
    <constraint field="perenniality" desc="" exp=""/>
  </constraintExpressions>
  <expressionfields/>
  <attributeactions>
    <defaultAction key="Canvas" value="{00000000-0000-0000-0000-000000000000}"/>
  </attributeactions>
  <attributetableconfig actionWidgetStyle="dropDown" sortExpression="" sortOrder="0">
    <columns>
      <column type="field" name="OBJECTID" width="-1" hidden="0"/>
      <column type="field" name="Permanent_Identifier" width="-1" hidden="0"/>
      <column type="field" name="FDate" width="-1" hidden="0"/>
      <column type="field" name="Resolution" width="-1" hidden="0"/>
      <column type="field" name="GNIS_ID" width="-1" hidden="0"/>
      <column type="field" name="GNIS_Name" width="-1" hidden="0"/>
      <column type="field" name="LengthKM" width="-1" hidden="0"/>
      <column type="field" name="ReachCode" width="-1" hidden="0"/>
      <column type="field" name="FlowDir" width="-1" hidden="0"/>
      <column type="field" name="WBArea_Permanent_Identifier" width="-1" hidden="0"/>
      <column type="field" name="FType" width="-1" hidden="0"/>
      <column type="field" name="FCode" width="-1" hidden="0"/>
      <column type="field" name="MainPath" width="-1" hidden="0"/>
      <column type="field" name="InNetwork" width="-1" hidden="0"/>
      <column type="field" name="VisibilityFilter" width="-1" hidden="0"/>
      <column type="field" name="Shape_Length" width="-1" hidden="0"/>
      <column type="field" name="NHDPlusID" width="-1" hidden="0"/>
      <column type="field" name="VPUID" width="-1" hidden="0"/>
      <column type="field" name="Enabled" width="-1" hidden="0"/>
      <column type="field" name="StreamOrde" width="-1" hidden="0"/>
      <column type="field" name="HydroSeq" width="-1" hidden="0"/>
      <column type="field" name="FromNode" width="-1" hidden="0"/>
      <column type="field" name="ToNode" width="-1" hidden="0"/>
      <column type="field" name="Q_cms" width="-1" hidden="0"/>
      <column type="field" name="width_m" width="-1" hidden="0"/>
      <column type="field" name="perenniality" width="-1" hidden="0"/>
      <column type="actions" width="-1" hidden="1"/>
      <column type="field" name="wtd_m_min" width="-1" hidden="0"/>
      <column type="field" name="wtd_m_median" width="-1" hidden="0"/>
      <column type="field" name="wtd_m_mean" width="-1" hidden="0"/>
      <column type="field" name="wtd_m_max" width="-1" hidden="0"/>
      <column type="field" name="depth_m" width="-1" hidden="0"/>
    </columns>
  </attributetableconfig>
  <conditionalstyles>
    <rowstyles/>
    <fieldstyles/>
  </conditionalstyles>
  <storedexpressions/>
  <editform tolerant="1"></editform>
  <editforminit/>
  <editforminitcodesource>0</editforminitcodesource>
  <editforminitfilepath></editforminitfilepath>
  <editforminitcode><![CDATA[# -*- coding: utf-8 -*-
"""
QGIS forms can have a Python function that is called when the form is
opened.

Use this function to add extra logic to your forms.

Enter the name of the function in the "Python Init function"
field.
An example follows:
"""
from qgis.PyQt.QtWidgets import QWidget

def my_form_open(dialog, layer, feature):
    geom = feature.geometry()
    control = dialog.findChild(QWidget, "MyLineEdit")
]]></editforminitcode>
  <featformsuppress>0</featformsuppress>
  <editorlayout>generatedlayout</editorlayout>
  <editable>
    <field name="1104_FromNode" editable="0"/>
    <field name="1104_HydroSeq" editable="0"/>
    <field name="1104_LengthKM" editable="0"/>
    <field name="1104_Q_cms" editable="0"/>
    <field name="1104_StreamOrde" editable="0"/>
    <field name="1104_ToNode" editable="0"/>
    <field name="1104_field_1" editable="0"/>
    <field name="1104_perenniality" editable="0"/>
    <field name="1104_width_m" editable="0"/>
    <field name="1104_wtd_m_01" editable="0"/>
    <field name="1104_wtd_m_02" editable="0"/>
    <field name="1104_wtd_m_03" editable="0"/>
    <field name="1104_wtd_m_04" editable="0"/>
    <field name="1104_wtd_m_05" editable="0"/>
    <field name="1104_wtd_m_06" editable="0"/>
    <field name="1104_wtd_m_07" editable="0"/>
    <field name="1104_wtd_m_08" editable="0"/>
    <field name="1104_wtd_m_09" editable="0"/>
    <field name="1104_wtd_m_10" editable="0"/>
    <field name="1104_wtd_m_11" editable="0"/>
    <field name="1104_wtd_m_12" editable="0"/>
    <field name="1104_wtd_sum" editable="0"/>
    <field name="1114_FromNode" editable="0"/>
    <field name="1114_HydroSeq" editable="0"/>
    <field name="1114_LengthKM" editable="0"/>
    <field name="1114_Q_cms" editable="0"/>
    <field name="1114_StreamOrde" editable="0"/>
    <field name="1114_ToNode" editable="0"/>
    <field name="1114_field_1" editable="0"/>
    <field name="1114_perenniality" editable="0"/>
    <field name="1114_width_m" editable="0"/>
    <field name="1114_wtd_m_01" editable="0"/>
    <field name="1114_wtd_m_02" editable="0"/>
    <field name="1114_wtd_m_03" editable="0"/>
    <field name="1114_wtd_m_04" editable="0"/>
    <field name="1114_wtd_m_05" editable="0"/>
    <field name="1114_wtd_m_06" editable="0"/>
    <field name="1114_wtd_m_07" editable="0"/>
    <field name="1114_wtd_m_08" editable="0"/>
    <field name="1114_wtd_m_09" editable="0"/>
    <field name="1114_wtd_m_10" editable="0"/>
    <field name="1114_wtd_m_11" editable="0"/>
    <field name="1114_wtd_m_12" editable="0"/>
    <field name="1114_wtd_sum" editable="0"/>
    <field name="Enabled" editable="1"/>
    <field name="FCode" editable="1"/>
    <field name="FDate" editable="1"/>
    <field name="FType" editable="1"/>
    <field name="FlowDir" editable="1"/>
    <field name="FromNode" editable="0"/>
    <field name="GNIS_ID" editable="1"/>
    <field name="GNIS_Name" editable="1"/>
    <field name="HydroSeq" editable="0"/>
    <field name="InNetwork" editable="1"/>
    <field name="LengthKM" editable="1"/>
    <field name="MainPath" editable="1"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_ArbolateSu" editable="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_AreaSqKm" editable="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_DivDASqKm" editable="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_Divergence" editable="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_DnDrainCou" editable="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_DnHydroSeq" editable="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_DnLevel" editable="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_DnLevelPat" editable="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_DnMinorHyd" editable="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_ElevFixed" editable="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_FromMeas" editable="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_FromNode" editable="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_HWNodeSqKm" editable="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_HWType" editable="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_HydroSeq" editable="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_LevelPathI" editable="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_MaxElevRaw" editable="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_MaxElevSmo" editable="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_MinElevRaw" editable="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_MinElevSmo" editable="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_OBJECTID" editable="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_PathLength" editable="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_ReachCode" editable="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_RtnDiv" editable="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_Slope" editable="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_SlopeLenKm" editable="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_StartFlag" editable="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_StatusFlag" editable="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_StreamCalc" editable="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_StreamLeve" editable="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_StreamOrde" editable="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_TerminalFl" editable="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_TerminalPa" editable="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_Thinner" editable="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_ToMeas" editable="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_ToNode" editable="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_TotDASqKm" editable="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_UpHydroSeq" editable="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_UpLevelPat" editable="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_VPUID" editable="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_VPUIn" editable="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_VPUOut" editable="0"/>
    <field name="NHDPlusID" editable="1"/>
    <field name="OBJECTID" editable="1"/>
    <field name="Permanent_Identifier" editable="1"/>
    <field name="Q_cms" editable="0"/>
    <field name="ReachCode" editable="1"/>
    <field name="Resolution" editable="1"/>
    <field name="Shape_Length" editable="1"/>
    <field name="StreamOrde" editable="0"/>
    <field name="ToNode" editable="0"/>
    <field name="VPUID" editable="1"/>
    <field name="VisibilityFilter" editable="1"/>
    <field name="WBArea_Permanent_Identifier" editable="1"/>
    <field name="depth_m" editable="0"/>
    <field name="field_1" editable="0"/>
    <field name="perenniality" editable="0"/>
    <field name="width_m" editable="0"/>
    <field name="wtd_m_01" editable="0"/>
    <field name="wtd_m_02" editable="0"/>
    <field name="wtd_m_03" editable="0"/>
    <field name="wtd_m_04" editable="0"/>
    <field name="wtd_m_05" editable="0"/>
    <field name="wtd_m_06" editable="0"/>
    <field name="wtd_m_07" editable="0"/>
    <field name="wtd_m_08" editable="0"/>
    <field name="wtd_m_09" editable="0"/>
    <field name="wtd_m_10" editable="0"/>
    <field name="wtd_m_11" editable="0"/>
    <field name="wtd_m_12" editable="0"/>
    <field name="wtd_m_max" editable="0"/>
    <field name="wtd_m_max_01" editable="0"/>
    <field name="wtd_m_max_02" editable="0"/>
    <field name="wtd_m_max_03" editable="0"/>
    <field name="wtd_m_max_04" editable="0"/>
    <field name="wtd_m_max_05" editable="0"/>
    <field name="wtd_m_max_06" editable="0"/>
    <field name="wtd_m_max_07" editable="0"/>
    <field name="wtd_m_max_08" editable="0"/>
    <field name="wtd_m_max_09" editable="0"/>
    <field name="wtd_m_max_10" editable="0"/>
    <field name="wtd_m_max_11" editable="0"/>
    <field name="wtd_m_max_12" editable="0"/>
    <field name="wtd_m_mean" editable="0"/>
    <field name="wtd_m_mean_01" editable="0"/>
    <field name="wtd_m_mean_02" editable="0"/>
    <field name="wtd_m_mean_03" editable="0"/>
    <field name="wtd_m_mean_04" editable="0"/>
    <field name="wtd_m_mean_05" editable="0"/>
    <field name="wtd_m_mean_06" editable="0"/>
    <field name="wtd_m_mean_07" editable="0"/>
    <field name="wtd_m_mean_08" editable="0"/>
    <field name="wtd_m_mean_09" editable="0"/>
    <field name="wtd_m_mean_10" editable="0"/>
    <field name="wtd_m_mean_11" editable="0"/>
    <field name="wtd_m_mean_12" editable="0"/>
    <field name="wtd_m_median" editable="0"/>
    <field name="wtd_m_median_01" editable="0"/>
    <field name="wtd_m_median_02" editable="0"/>
    <field name="wtd_m_median_03" editable="0"/>
    <field name="wtd_m_median_04" editable="0"/>
    <field name="wtd_m_median_05" editable="0"/>
    <field name="wtd_m_median_06" editable="0"/>
    <field name="wtd_m_median_07" editable="0"/>
    <field name="wtd_m_median_08" editable="0"/>
    <field name="wtd_m_median_09" editable="0"/>
    <field name="wtd_m_median_10" editable="0"/>
    <field name="wtd_m_median_11" editable="0"/>
    <field name="wtd_m_median_12" editable="0"/>
    <field name="wtd_m_min" editable="0"/>
    <field name="wtd_m_min_01" editable="0"/>
    <field name="wtd_m_min_02" editable="0"/>
    <field name="wtd_m_min_03" editable="0"/>
    <field name="wtd_m_min_04" editable="0"/>
    <field name="wtd_m_min_05" editable="0"/>
    <field name="wtd_m_min_06" editable="0"/>
    <field name="wtd_m_min_07" editable="0"/>
    <field name="wtd_m_min_08" editable="0"/>
    <field name="wtd_m_min_09" editable="0"/>
    <field name="wtd_m_min_10" editable="0"/>
    <field name="wtd_m_min_11" editable="0"/>
    <field name="wtd_m_min_12" editable="0"/>
    <field name="wtd_sum" editable="0"/>
  </editable>
  <labelOnTop>
    <field name="1104_FromNode" labelOnTop="0"/>
    <field name="1104_HydroSeq" labelOnTop="0"/>
    <field name="1104_LengthKM" labelOnTop="0"/>
    <field name="1104_Q_cms" labelOnTop="0"/>
    <field name="1104_StreamOrde" labelOnTop="0"/>
    <field name="1104_ToNode" labelOnTop="0"/>
    <field name="1104_field_1" labelOnTop="0"/>
    <field name="1104_perenniality" labelOnTop="0"/>
    <field name="1104_width_m" labelOnTop="0"/>
    <field name="1104_wtd_m_01" labelOnTop="0"/>
    <field name="1104_wtd_m_02" labelOnTop="0"/>
    <field name="1104_wtd_m_03" labelOnTop="0"/>
    <field name="1104_wtd_m_04" labelOnTop="0"/>
    <field name="1104_wtd_m_05" labelOnTop="0"/>
    <field name="1104_wtd_m_06" labelOnTop="0"/>
    <field name="1104_wtd_m_07" labelOnTop="0"/>
    <field name="1104_wtd_m_08" labelOnTop="0"/>
    <field name="1104_wtd_m_09" labelOnTop="0"/>
    <field name="1104_wtd_m_10" labelOnTop="0"/>
    <field name="1104_wtd_m_11" labelOnTop="0"/>
    <field name="1104_wtd_m_12" labelOnTop="0"/>
    <field name="1104_wtd_sum" labelOnTop="0"/>
    <field name="1114_FromNode" labelOnTop="0"/>
    <field name="1114_HydroSeq" labelOnTop="0"/>
    <field name="1114_LengthKM" labelOnTop="0"/>
    <field name="1114_Q_cms" labelOnTop="0"/>
    <field name="1114_StreamOrde" labelOnTop="0"/>
    <field name="1114_ToNode" labelOnTop="0"/>
    <field name="1114_field_1" labelOnTop="0"/>
    <field name="1114_perenniality" labelOnTop="0"/>
    <field name="1114_width_m" labelOnTop="0"/>
    <field name="1114_wtd_m_01" labelOnTop="0"/>
    <field name="1114_wtd_m_02" labelOnTop="0"/>
    <field name="1114_wtd_m_03" labelOnTop="0"/>
    <field name="1114_wtd_m_04" labelOnTop="0"/>
    <field name="1114_wtd_m_05" labelOnTop="0"/>
    <field name="1114_wtd_m_06" labelOnTop="0"/>
    <field name="1114_wtd_m_07" labelOnTop="0"/>
    <field name="1114_wtd_m_08" labelOnTop="0"/>
    <field name="1114_wtd_m_09" labelOnTop="0"/>
    <field name="1114_wtd_m_10" labelOnTop="0"/>
    <field name="1114_wtd_m_11" labelOnTop="0"/>
    <field name="1114_wtd_m_12" labelOnTop="0"/>
    <field name="1114_wtd_sum" labelOnTop="0"/>
    <field name="Enabled" labelOnTop="0"/>
    <field name="FCode" labelOnTop="0"/>
    <field name="FDate" labelOnTop="0"/>
    <field name="FType" labelOnTop="0"/>
    <field name="FlowDir" labelOnTop="0"/>
    <field name="FromNode" labelOnTop="0"/>
    <field name="GNIS_ID" labelOnTop="0"/>
    <field name="GNIS_Name" labelOnTop="0"/>
    <field name="HydroSeq" labelOnTop="0"/>
    <field name="InNetwork" labelOnTop="0"/>
    <field name="LengthKM" labelOnTop="0"/>
    <field name="MainPath" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_ArbolateSu" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_AreaSqKm" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_DivDASqKm" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_Divergence" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_DnDrainCou" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_DnHydroSeq" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_DnLevel" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_DnLevelPat" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_DnMinorHyd" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_ElevFixed" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_FromMeas" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_FromNode" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_HWNodeSqKm" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_HWType" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_HydroSeq" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_LevelPathI" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_MaxElevRaw" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_MaxElevSmo" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_MinElevRaw" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_MinElevSmo" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_OBJECTID" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_PathLength" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_ReachCode" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_RtnDiv" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_Slope" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_SlopeLenKm" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_StartFlag" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_StatusFlag" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_StreamCalc" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_StreamLeve" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_StreamOrde" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_TerminalFl" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_TerminalPa" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_Thinner" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_ToMeas" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_ToNode" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_TotDASqKm" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_UpHydroSeq" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_UpLevelPat" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_VPUID" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_VPUIn" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_VPUOut" labelOnTop="0"/>
    <field name="NHDPlusID" labelOnTop="0"/>
    <field name="OBJECTID" labelOnTop="0"/>
    <field name="Permanent_Identifier" labelOnTop="0"/>
    <field name="Q_cms" labelOnTop="0"/>
    <field name="ReachCode" labelOnTop="0"/>
    <field name="Resolution" labelOnTop="0"/>
    <field name="Shape_Length" labelOnTop="0"/>
    <field name="StreamOrde" labelOnTop="0"/>
    <field name="ToNode" labelOnTop="0"/>
    <field name="VPUID" labelOnTop="0"/>
    <field name="VisibilityFilter" labelOnTop="0"/>
    <field name="WBArea_Permanent_Identifier" labelOnTop="0"/>
    <field name="depth_m" labelOnTop="0"/>
    <field name="field_1" labelOnTop="0"/>
    <field name="perenniality" labelOnTop="0"/>
    <field name="width_m" labelOnTop="0"/>
    <field name="wtd_m_01" labelOnTop="0"/>
    <field name="wtd_m_02" labelOnTop="0"/>
    <field name="wtd_m_03" labelOnTop="0"/>
    <field name="wtd_m_04" labelOnTop="0"/>
    <field name="wtd_m_05" labelOnTop="0"/>
    <field name="wtd_m_06" labelOnTop="0"/>
    <field name="wtd_m_07" labelOnTop="0"/>
    <field name="wtd_m_08" labelOnTop="0"/>
    <field name="wtd_m_09" labelOnTop="0"/>
    <field name="wtd_m_10" labelOnTop="0"/>
    <field name="wtd_m_11" labelOnTop="0"/>
    <field name="wtd_m_12" labelOnTop="0"/>
    <field name="wtd_m_max" labelOnTop="0"/>
    <field name="wtd_m_max_01" labelOnTop="0"/>
    <field name="wtd_m_max_02" labelOnTop="0"/>
    <field name="wtd_m_max_03" labelOnTop="0"/>
    <field name="wtd_m_max_04" labelOnTop="0"/>
    <field name="wtd_m_max_05" labelOnTop="0"/>
    <field name="wtd_m_max_06" labelOnTop="0"/>
    <field name="wtd_m_max_07" labelOnTop="0"/>
    <field name="wtd_m_max_08" labelOnTop="0"/>
    <field name="wtd_m_max_09" labelOnTop="0"/>
    <field name="wtd_m_max_10" labelOnTop="0"/>
    <field name="wtd_m_max_11" labelOnTop="0"/>
    <field name="wtd_m_max_12" labelOnTop="0"/>
    <field name="wtd_m_mean" labelOnTop="0"/>
    <field name="wtd_m_mean_01" labelOnTop="0"/>
    <field name="wtd_m_mean_02" labelOnTop="0"/>
    <field name="wtd_m_mean_03" labelOnTop="0"/>
    <field name="wtd_m_mean_04" labelOnTop="0"/>
    <field name="wtd_m_mean_05" labelOnTop="0"/>
    <field name="wtd_m_mean_06" labelOnTop="0"/>
    <field name="wtd_m_mean_07" labelOnTop="0"/>
    <field name="wtd_m_mean_08" labelOnTop="0"/>
    <field name="wtd_m_mean_09" labelOnTop="0"/>
    <field name="wtd_m_mean_10" labelOnTop="0"/>
    <field name="wtd_m_mean_11" labelOnTop="0"/>
    <field name="wtd_m_mean_12" labelOnTop="0"/>
    <field name="wtd_m_median" labelOnTop="0"/>
    <field name="wtd_m_median_01" labelOnTop="0"/>
    <field name="wtd_m_median_02" labelOnTop="0"/>
    <field name="wtd_m_median_03" labelOnTop="0"/>
    <field name="wtd_m_median_04" labelOnTop="0"/>
    <field name="wtd_m_median_05" labelOnTop="0"/>
    <field name="wtd_m_median_06" labelOnTop="0"/>
    <field name="wtd_m_median_07" labelOnTop="0"/>
    <field name="wtd_m_median_08" labelOnTop="0"/>
    <field name="wtd_m_median_09" labelOnTop="0"/>
    <field name="wtd_m_median_10" labelOnTop="0"/>
    <field name="wtd_m_median_11" labelOnTop="0"/>
    <field name="wtd_m_median_12" labelOnTop="0"/>
    <field name="wtd_m_min" labelOnTop="0"/>
    <field name="wtd_m_min_01" labelOnTop="0"/>
    <field name="wtd_m_min_02" labelOnTop="0"/>
    <field name="wtd_m_min_03" labelOnTop="0"/>
    <field name="wtd_m_min_04" labelOnTop="0"/>
    <field name="wtd_m_min_05" labelOnTop="0"/>
    <field name="wtd_m_min_06" labelOnTop="0"/>
    <field name="wtd_m_min_07" labelOnTop="0"/>
    <field name="wtd_m_min_08" labelOnTop="0"/>
    <field name="wtd_m_min_09" labelOnTop="0"/>
    <field name="wtd_m_min_10" labelOnTop="0"/>
    <field name="wtd_m_min_11" labelOnTop="0"/>
    <field name="wtd_m_min_12" labelOnTop="0"/>
    <field name="wtd_sum" labelOnTop="0"/>
  </labelOnTop>
  <reuseLastValue>
    <field reuseLastValue="0" name="1104_FromNode"/>
    <field reuseLastValue="0" name="1104_HydroSeq"/>
    <field reuseLastValue="0" name="1104_LengthKM"/>
    <field reuseLastValue="0" name="1104_Q_cms"/>
    <field reuseLastValue="0" name="1104_StreamOrde"/>
    <field reuseLastValue="0" name="1104_ToNode"/>
    <field reuseLastValue="0" name="1104_field_1"/>
    <field reuseLastValue="0" name="1104_perenniality"/>
    <field reuseLastValue="0" name="1104_width_m"/>
    <field reuseLastValue="0" name="1104_wtd_m_01"/>
    <field reuseLastValue="0" name="1104_wtd_m_02"/>
    <field reuseLastValue="0" name="1104_wtd_m_03"/>
    <field reuseLastValue="0" name="1104_wtd_m_04"/>
    <field reuseLastValue="0" name="1104_wtd_m_05"/>
    <field reuseLastValue="0" name="1104_wtd_m_06"/>
    <field reuseLastValue="0" name="1104_wtd_m_07"/>
    <field reuseLastValue="0" name="1104_wtd_m_08"/>
    <field reuseLastValue="0" name="1104_wtd_m_09"/>
    <field reuseLastValue="0" name="1104_wtd_m_10"/>
    <field reuseLastValue="0" name="1104_wtd_m_11"/>
    <field reuseLastValue="0" name="1104_wtd_m_12"/>
    <field reuseLastValue="0" name="1104_wtd_sum"/>
    <field reuseLastValue="0" name="1114_FromNode"/>
    <field reuseLastValue="0" name="1114_HydroSeq"/>
    <field reuseLastValue="0" name="1114_LengthKM"/>
    <field reuseLastValue="0" name="1114_Q_cms"/>
    <field reuseLastValue="0" name="1114_StreamOrde"/>
    <field reuseLastValue="0" name="1114_ToNode"/>
    <field reuseLastValue="0" name="1114_field_1"/>
    <field reuseLastValue="0" name="1114_perenniality"/>
    <field reuseLastValue="0" name="1114_width_m"/>
    <field reuseLastValue="0" name="1114_wtd_m_01"/>
    <field reuseLastValue="0" name="1114_wtd_m_02"/>
    <field reuseLastValue="0" name="1114_wtd_m_03"/>
    <field reuseLastValue="0" name="1114_wtd_m_04"/>
    <field reuseLastValue="0" name="1114_wtd_m_05"/>
    <field reuseLastValue="0" name="1114_wtd_m_06"/>
    <field reuseLastValue="0" name="1114_wtd_m_07"/>
    <field reuseLastValue="0" name="1114_wtd_m_08"/>
    <field reuseLastValue="0" name="1114_wtd_m_09"/>
    <field reuseLastValue="0" name="1114_wtd_m_10"/>
    <field reuseLastValue="0" name="1114_wtd_m_11"/>
    <field reuseLastValue="0" name="1114_wtd_m_12"/>
    <field reuseLastValue="0" name="1114_wtd_sum"/>
    <field reuseLastValue="0" name="Enabled"/>
    <field reuseLastValue="0" name="FCode"/>
    <field reuseLastValue="0" name="FDate"/>
    <field reuseLastValue="0" name="FType"/>
    <field reuseLastValue="0" name="FlowDir"/>
    <field reuseLastValue="0" name="FromNode"/>
    <field reuseLastValue="0" name="GNIS_ID"/>
    <field reuseLastValue="0" name="GNIS_Name"/>
    <field reuseLastValue="0" name="HydroSeq"/>
    <field reuseLastValue="0" name="InNetwork"/>
    <field reuseLastValue="0" name="LengthKM"/>
    <field reuseLastValue="0" name="MainPath"/>
    <field reuseLastValue="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_ArbolateSu"/>
    <field reuseLastValue="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_AreaSqKm"/>
    <field reuseLastValue="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_DivDASqKm"/>
    <field reuseLastValue="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_Divergence"/>
    <field reuseLastValue="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_DnDrainCou"/>
    <field reuseLastValue="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_DnHydroSeq"/>
    <field reuseLastValue="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_DnLevel"/>
    <field reuseLastValue="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_DnLevelPat"/>
    <field reuseLastValue="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_DnMinorHyd"/>
    <field reuseLastValue="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_ElevFixed"/>
    <field reuseLastValue="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_FromMeas"/>
    <field reuseLastValue="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_FromNode"/>
    <field reuseLastValue="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_HWNodeSqKm"/>
    <field reuseLastValue="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_HWType"/>
    <field reuseLastValue="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_HydroSeq"/>
    <field reuseLastValue="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_LevelPathI"/>
    <field reuseLastValue="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_MaxElevRaw"/>
    <field reuseLastValue="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_MaxElevSmo"/>
    <field reuseLastValue="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_MinElevRaw"/>
    <field reuseLastValue="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_MinElevSmo"/>
    <field reuseLastValue="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_OBJECTID"/>
    <field reuseLastValue="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_PathLength"/>
    <field reuseLastValue="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_ReachCode"/>
    <field reuseLastValue="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_RtnDiv"/>
    <field reuseLastValue="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_Slope"/>
    <field reuseLastValue="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_SlopeLenKm"/>
    <field reuseLastValue="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_StartFlag"/>
    <field reuseLastValue="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_StatusFlag"/>
    <field reuseLastValue="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_StreamCalc"/>
    <field reuseLastValue="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_StreamLeve"/>
    <field reuseLastValue="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_StreamOrde"/>
    <field reuseLastValue="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_TerminalFl"/>
    <field reuseLastValue="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_TerminalPa"/>
    <field reuseLastValue="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_Thinner"/>
    <field reuseLastValue="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_ToMeas"/>
    <field reuseLastValue="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_ToNode"/>
    <field reuseLastValue="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_TotDASqKm"/>
    <field reuseLastValue="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_UpHydroSeq"/>
    <field reuseLastValue="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_UpLevelPat"/>
    <field reuseLastValue="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_VPUID"/>
    <field reuseLastValue="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_VPUIn"/>
    <field reuseLastValue="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_VPUOut"/>
    <field reuseLastValue="0" name="NHDPlusID"/>
    <field reuseLastValue="0" name="OBJECTID"/>
    <field reuseLastValue="0" name="Permanent_Identifier"/>
    <field reuseLastValue="0" name="Q_cms"/>
    <field reuseLastValue="0" name="ReachCode"/>
    <field reuseLastValue="0" name="Resolution"/>
    <field reuseLastValue="0" name="Shape_Length"/>
    <field reuseLastValue="0" name="StreamOrde"/>
    <field reuseLastValue="0" name="ToNode"/>
    <field reuseLastValue="0" name="VPUID"/>
    <field reuseLastValue="0" name="VisibilityFilter"/>
    <field reuseLastValue="0" name="WBArea_Permanent_Identifier"/>
    <field reuseLastValue="0" name="depth_m"/>
    <field reuseLastValue="0" name="field_1"/>
    <field reuseLastValue="0" name="perenniality"/>
    <field reuseLastValue="0" name="width_m"/>
    <field reuseLastValue="0" name="wtd_m_01"/>
    <field reuseLastValue="0" name="wtd_m_02"/>
    <field reuseLastValue="0" name="wtd_m_03"/>
    <field reuseLastValue="0" name="wtd_m_04"/>
    <field reuseLastValue="0" name="wtd_m_05"/>
    <field reuseLastValue="0" name="wtd_m_06"/>
    <field reuseLastValue="0" name="wtd_m_07"/>
    <field reuseLastValue="0" name="wtd_m_08"/>
    <field reuseLastValue="0" name="wtd_m_09"/>
    <field reuseLastValue="0" name="wtd_m_10"/>
    <field reuseLastValue="0" name="wtd_m_11"/>
    <field reuseLastValue="0" name="wtd_m_12"/>
    <field reuseLastValue="0" name="wtd_m_max"/>
    <field reuseLastValue="0" name="wtd_m_max_01"/>
    <field reuseLastValue="0" name="wtd_m_max_02"/>
    <field reuseLastValue="0" name="wtd_m_max_03"/>
    <field reuseLastValue="0" name="wtd_m_max_04"/>
    <field reuseLastValue="0" name="wtd_m_max_05"/>
    <field reuseLastValue="0" name="wtd_m_max_06"/>
    <field reuseLastValue="0" name="wtd_m_max_07"/>
    <field reuseLastValue="0" name="wtd_m_max_08"/>
    <field reuseLastValue="0" name="wtd_m_max_09"/>
    <field reuseLastValue="0" name="wtd_m_max_10"/>
    <field reuseLastValue="0" name="wtd_m_max_11"/>
    <field reuseLastValue="0" name="wtd_m_max_12"/>
    <field reuseLastValue="0" name="wtd_m_mean"/>
    <field reuseLastValue="0" name="wtd_m_mean_01"/>
    <field reuseLastValue="0" name="wtd_m_mean_02"/>
    <field reuseLastValue="0" name="wtd_m_mean_03"/>
    <field reuseLastValue="0" name="wtd_m_mean_04"/>
    <field reuseLastValue="0" name="wtd_m_mean_05"/>
    <field reuseLastValue="0" name="wtd_m_mean_06"/>
    <field reuseLastValue="0" name="wtd_m_mean_07"/>
    <field reuseLastValue="0" name="wtd_m_mean_08"/>
    <field reuseLastValue="0" name="wtd_m_mean_09"/>
    <field reuseLastValue="0" name="wtd_m_mean_10"/>
    <field reuseLastValue="0" name="wtd_m_mean_11"/>
    <field reuseLastValue="0" name="wtd_m_mean_12"/>
    <field reuseLastValue="0" name="wtd_m_median"/>
    <field reuseLastValue="0" name="wtd_m_median_01"/>
    <field reuseLastValue="0" name="wtd_m_median_02"/>
    <field reuseLastValue="0" name="wtd_m_median_03"/>
    <field reuseLastValue="0" name="wtd_m_median_04"/>
    <field reuseLastValue="0" name="wtd_m_median_05"/>
    <field reuseLastValue="0" name="wtd_m_median_06"/>
    <field reuseLastValue="0" name="wtd_m_median_07"/>
    <field reuseLastValue="0" name="wtd_m_median_08"/>
    <field reuseLastValue="0" name="wtd_m_median_09"/>
    <field reuseLastValue="0" name="wtd_m_median_10"/>
    <field reuseLastValue="0" name="wtd_m_median_11"/>
    <field reuseLastValue="0" name="wtd_m_median_12"/>
    <field reuseLastValue="0" name="wtd_m_min"/>
    <field reuseLastValue="0" name="wtd_m_min_01"/>
    <field reuseLastValue="0" name="wtd_m_min_02"/>
    <field reuseLastValue="0" name="wtd_m_min_03"/>
    <field reuseLastValue="0" name="wtd_m_min_04"/>
    <field reuseLastValue="0" name="wtd_m_min_05"/>
    <field reuseLastValue="0" name="wtd_m_min_06"/>
    <field reuseLastValue="0" name="wtd_m_min_07"/>
    <field reuseLastValue="0" name="wtd_m_min_08"/>
    <field reuseLastValue="0" name="wtd_m_min_09"/>
    <field reuseLastValue="0" name="wtd_m_min_10"/>
    <field reuseLastValue="0" name="wtd_m_min_11"/>
    <field reuseLastValue="0" name="wtd_m_min_12"/>
    <field reuseLastValue="0" name="wtd_sum"/>
  </reuseLastValue>
  <dataDefinedFieldProperties/>
  <widgets/>
  <previewExpression>"GNIS_Name"</previewExpression>
  <mapTip></mapTip>
  <layerGeometryType>1</layerGeometryType>
</qgis>
