//
//  ViewController.m
//  MacOSDemo
//
//  Created by 王腾 on 2022/9/27.
//

#import "ViewController.h"
#import <Masonry/Masonry.h>
#import "WTSongListTableCellView.h"
#import <AVKit/AVKit.h>
#import "WTSettingVc.h"

@interface ViewController ()<NSTableViewDelegate,NSTableViewDataSource>

@property (nonatomic, strong) NSButton *openButton;

@property (nonatomic, strong) NSTextField *titleLabel;

@property (nonatomic, strong) NSTextField *songNameLabel;

@property (nonatomic, strong) NSTableView *tableView;

@property (nonatomic, strong) NSMutableArray *results;

@property (nonatomic, strong) NSMutableArray *pathResults;

@property (nonatomic, strong) AVPlayer *player;

@property (nonatomic, strong) NSButton *setButton;
@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = @"WT音乐";

    [self setUpUI];
    // Do any additional setup after loading the view.
}
- (void)setUpUI {
    
    self.titleLabel = ({
       
        NSTextField *label = [[NSTextField alloc] init];
        label.stringValue = @"当前歌曲名字：";
        label.editable = NO;
        label.font = [NSFont menuFontOfSize:12];
        [self.view addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.leading.top.equalTo(self.view).offset(10);
        }];
        label;
    });
    self.songNameLabel = ({
       
        NSTextField *label = [[NSTextField alloc] init];
        label.editable = NO;
        label.font = [NSFont menuFontOfSize:12];
        [self.view addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.leading.equalTo(self.titleLabel.mas_trailing).offset(20);
            make.centerY.equalTo(self.titleLabel);
            make.size.mas_equalTo(CGSizeMake(200, 20));
        }];
        label;
    });
    self.openButton = [[NSButton alloc] init];
    [self.openButton setTarget:self];
    [self.openButton setAction:@selector(buttonClick)];
    [self.openButton setTitle:@"读取文件"];
    [self.openButton setFont:[NSFont systemFontOfSize:12]];
    [self.view addSubview:self.openButton];
    
    [self.openButton mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.leading.equalTo(self.songNameLabel.mas_trailing).offset(20);
        make.centerY.equalTo(self.songNameLabel);
    }];
    
    self.setButton = ({
       
        NSButton *button = [[NSButton alloc] init];
        
        [button setTarget:self];
        [button setAction:@selector(setButtonClick)];
        [button setTitle:@"设置"];
        [button setFont:[NSFont systemFontOfSize:12]];
        [self.view addSubview:button];
        
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.leading.equalTo(self.openButton.mas_trailing).offset(20);
            make.centerY.equalTo(self.openButton);
        }];
        button;
    });
    
    self.tableView = ({
       
        NSTableView *tableView = [[NSTableView alloc] init];
        tableView.delegate = self;
        tableView.dataSource = self;
        NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:@"WTSongListTableCellView"];
        [tableView addTableColumn:column];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.top.equalTo(self.songNameLabel.mas_bottom).offset(10);
            make.leading.trailing.equalTo(self.view);
        }];
        tableView;
    });
    
}
- (void)setButtonClick {
    WTSettingVc *setVc = [[WTSettingVc alloc] initWithWindowNibName:@"WTSettingVc"];
    [setVc showWindow:self];
//    [setVc presentingViewController];
}
- (void)buttonClick {
    
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    
    panel.allowedFileTypes = @[@"mp3"];
    [panel setAllowsMultipleSelection:YES];  //是否允许多选file
    
    [panel beginWithCompletionHandler:^(NSInteger result) {
        if (result == NSModalResponseOK) {
            
            [self.results removeAllObjects];
            for (NSURL* elemnet in [panel URLs]) {
                [self.pathResults addObject:[elemnet path]];
            }
            for (NSString *path in self.pathResults) {
                NSArray *array = [path componentsSeparatedByString:@"/"];
                [self.results addObject:[array lastObject]];
            }
            [self.tableView reloadData];
            NSLog(@"filePaths : %@",self.pathResults);
        }
        
    }];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    
    return self.results.count;
}
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    return self.results[row];
}
//设置鼠标悬停在cell上显示的提示文本
- (NSString *)tableView:(NSTableView *)tableView toolTipForCell:(NSCell *)cell rect:(NSRectPointer)rect tableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row mouseLocation:(NSPoint)mouseLocation{
    NSString *name = self.results[row];
    return [NSString stringWithFormat:@"您确定播放：%@这首歌吗？点击即可播放！",name];
}
- (BOOL)tableView:(NSTableView *)tableView shouldTrackCell:(NSCell *)cell forTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    return YES;
}
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if (tableColumn != nil) {
        WTSongListTableCellView * cell = [[WTSongListTableCellView alloc] initWithFrame:NSRectFromCGRect(CGRectMake(0, 0, 200, 40))];
        cell.name = self.results[row];
        return cell;
    }
    return nil;
}
- (NSIndexSet *)tableView:(NSTableView *)tableView selectionIndexesForProposedSelection:(NSIndexSet *)proposedSelectionIndexes {
    int index = proposedSelectionIndexes.lastIndex;
    if (index < 0 || index >= self.results.count) {
        return proposedSelectionIndexes;
    }
    self.songNameLabel.stringValue = self.results[index];
    NSString *path = self.pathResults[index];
    [self.player pause];
    AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:[NSURL fileURLWithPath:path]];
    [self.player replaceCurrentItemWithPlayerItem:item];
    [self.player play];
    return proposedSelectionIndexes;
}
- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    
    return 40;
}
- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

#pragma mark init

- (NSMutableArray *)results {
    
    if (!_results) {
        
        _results = [NSMutableArray array];
    }
    return _results;
}
- (NSMutableArray *)pathResults {
    
    if (!_pathResults) {
        
        _pathResults = [NSMutableArray array];
    }
    return _pathResults;
}
- (AVPlayer *)player {
    
    if (!_player) {
        
        _player = [[AVPlayer alloc] init];
    }
    return _player;
}
@end
