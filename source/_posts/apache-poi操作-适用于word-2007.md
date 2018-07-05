---
title: apache poi操作(适用于word 2007)
date: 2017-02-18 22:08:03
categories: Java二三事
tags:
	- Java
---
适用于word 2007 poi 版本 3.7
<!--more-->
```
import java.io.FileOutputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;

import org.apache.poi.POIXMLDocument;
import org.apache.poi.openxml4j.opc.OPCPackage;
import org.apache.poi.xwpf.usermodel.XWPFDocument;
import org.apache.poi.xwpf.usermodel.XWPFParagraph;
import org.apache.poi.xwpf.usermodel.XWPFRun;
import org.apache.poi.xwpf.usermodel.XWPFTable;
import org.apache.poi.xwpf.usermodel.XWPFTableCell;
import org.apache.poi.xwpf.usermodel.XWPFTableRow;

/**
 * 适用于word 2007 poi 版本 3.7
 */
public class WordPoiUtil {

    /**
     * 根据指定的参数值、模板，生成 word 文档
     * 
     * @param param
     *            需要替换的变量
     * @param template
     *            模板
     */
    public static XWPFDocument generateWord(Map<String, Object> param,
            String template) {
        XWPFDocument doc = null;
        try {
            OPCPackage pack = POIXMLDocument.openPackage(template);
            doc = new XWPFDocument(pack);
            if (param != null && param.size() > 0) {

                // 处理段落
                List<XWPFParagraph> paragraphList = doc.getParagraphs();
                processParagraphs(paragraphList, param, doc);

                // 处理表格
                Iterator<XWPFTable> it = doc.getTablesIterator();
                while (it.hasNext()) {
                    XWPFTable table = it.next();
                    List<XWPFTableRow> rows = table.getRows();
                    for (XWPFTableRow row : rows) {
                        List<XWPFTableCell> cells = row.getTableCells();
                        for (XWPFTableCell cell : cells) {
                            List<XWPFParagraph> paragraphListTable = cell
                                    .getParagraphs();
                            processParagraphs(paragraphListTable, param, doc);
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return doc;
    }

    /**
     * 处理段落
     * 
     * @param paragraphList
     */
    public static void processParagraphs(List<XWPFParagraph> paragraphList,
            Map<String, Object> param, XWPFDocument doc) {
        if (paragraphList != null && paragraphList.size() > 0) {
            for (XWPFParagraph paragraph : paragraphList) {
                boolean addReplace = false;
                List<XWPFRun> runs = paragraph.getRuns();
                //每个需要替换的key的run的位置的集合
                List<Integer> replaceRuns = new ArrayList<Integer>();
                //每个段落的所有的key run的集合
                List<List<Integer>> perReplaceRunList = new ArrayList<List<Integer>>();
                for (int i = 0; i< runs.size();i++){
                    String text = runs.get(i).getText(0);
                    if(addReplace){
                        replaceRuns.add(i);
                    }
                    if(text != null && text.contains("#")){
                        addReplace = true;
                        replaceRuns.add(i);
                    }
                    if(text != null && text.contains("}")){
                        addReplace = false;
                        perReplaceRunList.add(replaceRuns);
                        replaceRuns = new ArrayList<Integer>();
                    }
                }

                for(int i=0;i<perReplaceRunList.size();i++){
                    List<Integer> runsList = perReplaceRunList.get(i);
                    System.out.println("==========================");
                    StringBuffer textSb = new StringBuffer();
                    for(int j = 0;j<runsList.size();j++){
                        System.out.println("============replace_runs"+runs.get(runsList.get(j)).getText(0));
                        textSb.append(runs.get(runsList.get(j)).getText(0));
                    }
                    String replaceStr = textSb.toString();
                    for(int j = 0; j<runsList.size();j++){
                        for (Entry<String, Object> entry : param.entrySet()) {
                            String key = entry.getKey();
                            if (replaceStr.indexOf(key) != -1) {
                                Object value = entry.getValue();
                                if (value instanceof String) {// 文本替换
                                    replaceStr = replaceStr.replace(key, value.toString());
                                }
                            }
                        }
                    }
                    System.out.println("==========="+replaceStr);
                    for(int j = 0;j<runsList.size();j++){
                        if(j == 0){
                            runs.get(runsList.get(j)).setText(replaceStr, 0);
                        }else{
                            runs.get(runsList.get(j)).setText("", 0);
                        }
                    }
                    for(int j = 0;j<runsList.size();j++){
                        System.out.println("============转换后"+runs.get(runsList.get(j)).getText(0));
                    }

                }

            }
        }
    }

    public static List<String> getReplaceFields(String template){
        List<String> replaceFields = new ArrayList<String>();
        XWPFDocument doc = null;
        try {
            OPCPackage pack = POIXMLDocument.openPackage(template);
            doc = new XWPFDocument(pack);
            // 处理段落
            List<XWPFParagraph> paragraphList = doc.getParagraphs();
            replaceFields.addAll(getFields(paragraphList));

            // 处理表格
            Iterator<XWPFTable> it = doc.getTablesIterator();
            while (it.hasNext()) {
                XWPFTable table = it.next();
                List<XWPFTableRow> rows = table.getRows();
                for (XWPFTableRow row : rows) {
                    List<XWPFTableCell> cells = row.getTableCells();
                    for (XWPFTableCell cell : cells) {
                        List<XWPFParagraph> paragraphListTable = cell
                                .getParagraphs();
                        replaceFields.addAll(getFields(paragraphListTable));
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return replaceFields;
    }

    /**
     * 获取段落的需要替换的字段
     * @param paragraphList
     * @return
     */
    public static List<String> getFields(List<XWPFParagraph> paragraphList) {
        List<String> fieldList = new ArrayList<String>();
        if (paragraphList != null && paragraphList.size() > 0) {
            for (XWPFParagraph paragraph : paragraphList) {
                boolean addReplace = false;
                List<XWPFRun> runs = paragraph.getRuns();
                //每个需要替换的key的run的位置的集合
                List<Integer> replaceRuns = new ArrayList<Integer>();
                //每个段落的所有的key run的集合
                List<List<Integer>> perReplaceRunList = new ArrayList<List<Integer>>();
                for (int i = 0; i< runs.size();i++){
                    String text = runs.get(i).getText(0);
                    if(addReplace){
                        replaceRuns.add(i);
                    }
                    if(text != null && text.contains("#")){
                        addReplace = true;
                        replaceRuns.add(i);
                    }
                    if(text != null && text.contains("}")){
                        addReplace = false;
                        perReplaceRunList.add(replaceRuns);
                        replaceRuns = new ArrayList<Integer>();
                    }
                }

                for(int i=0;i<perReplaceRunList.size();i++){
                    List<Integer> runsList = perReplaceRunList.get(i);
                    System.out.println("==========================");
                    StringBuffer textSb = new StringBuffer();
                    for(int j = 0;j<runsList.size();j++){
                        System.out.println("============replace_runs"+runs.get(runsList.get(j)).getText(0));
                        textSb.append(runs.get(runsList.get(j)).getText(0));
                    }
                    String replaceStr = textSb.toString().trim();
                    System.out.println("====replaceStr=" + replaceStr.substring(replaceStr.indexOf("#")+2,replaceStr.length()-1));
//                  System.out.println(replaceStr.substring(2,replaceStr.length()-1));
                    fieldList.add(replaceStr.substring(replaceStr.indexOf("#")+2,replaceStr.length()-1));

                }

            }
        }
        return fieldList;
    }
}
```